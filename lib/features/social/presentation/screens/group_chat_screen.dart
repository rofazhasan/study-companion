import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../data/models/social_models.dart';
import '../../data/repositories/social_repository.dart';
import '../providers/social_provider.dart';
import 'group_info_screen.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentUserId;
  
  // Reply State
  SocialChatMessage? _replyingTo;

  // Typing State
  Timer? _typingTimer;
  bool _isTyping = false;
  
  // Mention State
  List<Map<String, String>> _allMembers = [];
  List<Map<String, String>> _mentionMatches = [];
  bool _showMentionList = false;
  String _mentionQuery = '';
  
  // User Info
  String _currentUserName = 'User';

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _messageController.addListener(_onTextChanged);
    // Set active chat to suppress notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socialRepositoryProvider).setActiveChat(widget.groupId);
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (_currentUserId != null) {
      // Fetch my real name
      final name = await ref.read(socialRepositoryProvider).getMemberName(_currentUserId!);
      if (mounted) {
        setState(() {
          _currentUserName = name;
        });
      }
      // Mark messages as read
      ref.read(socialRepositoryProvider).markMessagesAsRead(widget.groupId, _currentUserId!);
    }
    // Fetch group members for mentions
    _allMembers = await ref.read(socialRepositoryProvider).getGroupMembers(widget.groupId);
  }

  @override
  void dispose() {
    // Clear active chat
    ref.read(socialRepositoryProvider).setActiveChat(null);
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (_currentUserId == null) return;
    
    final text = _messageController.text;
    final selection = _messageController.selection;
    
    // Typing Indicator Logic
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _sendTypingStatus(true);
    } 
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _sendTypingStatus(false);
      }
    });

    // Mention Logic
    if (selection.baseOffset >= 0) {
      final textBeforeCursor = text.substring(0, selection.baseOffset);
      final lastAt = textBeforeCursor.lastIndexOf('@');
      
      if (lastAt != -1) {
        final query = textBeforeCursor.substring(lastAt + 1);
        // Check if there's a space after @, if so, stop searching unless it's part of a name we are typing?
        // Simple logic: if query contains space, maybe stop. But names have spaces.
        // Let's allow spaces for now but maybe limit length or check if we are still "in" a mention.
        
        setState(() {
          _mentionQuery = query.toLowerCase();
          _mentionMatches = _allMembers.where((m) {
            final name = m['name']?.toLowerCase() ?? '';
            return name.contains(_mentionQuery);
          }).toList();
          _showMentionList = _mentionMatches.isNotEmpty;
        });
      } else {
        setState(() {
          _showMentionList = false;
        });
      }
    }
  }

  void _insertMention(Map<String, String> member) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final textBeforeCursor = text.substring(0, selection.baseOffset);
    final lastAt = textBeforeCursor.lastIndexOf('@');
    
    if (lastAt != -1) {
      final newText = text.replaceRange(lastAt, selection.baseOffset, '@${member['name']} ');
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lastAt + member['name']!.length + 2),
      );
    }
    
    setState(() {
      _showMentionList = false;
    });
  }

  void _sendTypingStatus(bool isTyping) {
    if (_currentUserId == null) return;
    // Use the fetched real name
    ref.read(socialRepositoryProvider).sendTypingStatus(widget.groupId, _currentUserId!, _currentUserName, isTyping);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    if (_currentUserId == null) return;
    
    _typingTimer?.cancel();
    _isTyping = false;
    _sendTypingStatus(false);

    final content = _messageController.text.trim();
    // Use the fetched real name for sending messages too, or fallback to what we had
    final senderName = _currentUserName; 

    // Extract mentions
    List<String> mentions = [];
    for (final member in _allMembers) {
      if (content.contains('@${member['name']}')) {
        mentions.add(member['id']!);
      }
    }



    ref.read(socialRepositoryProvider).sendMessage(
      widget.groupId, 
      _currentUserId!, 
      senderName, 
      content,
      replyToId: _replyingTo?.messageId,
      replyToContent: _replyingTo?.content,
      replyToSenderName: _replyingTo?.senderName,
      mentions: mentions,
    );
    
    _messageController.clear();
    setState(() {
      _replyingTo = null;
      _showMentionList = false;
    });
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(groupChatProvider(widget.groupId));
    final typingUsersAsync = ref.watch(typingStatusProvider(widget.groupId));
    
    // Access Control: Watch the group list to see if we are still a member
    final groupsAsync = ref.watch(socialNotifierProvider);
    
    int memberCount = 0;

    // We use a listener here to navigate away if we are removed
    ref.listen(socialNotifierProvider, (previous, next) {
      next.whenData((groups) {
        final group = groups.where((g) => g.groupId == widget.groupId).firstOrNull;
        if (group == null) {
          // We are no longer a member (kicked, banned, or left)
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are no longer a member of this group.')));
             context.go('/social');
          }
        }
      });
    });
    
    // Get member count for read receipts
    groupsAsync.whenData((groups) {
      final group = groups.where((g) => g.groupId == widget.groupId).firstOrNull;
      if (group != null) {
        memberCount = group.memberCount;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.groupName, style: const TextStyle(fontSize: 16)),
              ],
            ),
            typingUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Text('Tap for info', style: TextStyle(fontSize: 12, color: Colors.grey));
                }
                String text;
                if (users.length <= 3) {
                  text = '${users.join(", ")} ${users.length == 1 ? "is" : "are"} typing...';
                } else {
                  text = '${users.take(2).join(", ")} and ${users.length - 2} others are typing...';
                }
                return Text(text, style: const TextStyle(fontSize: 12, color: Colors.green, fontStyle: FontStyle.italic));
              },
              loading: () => const Text('Tap for info', style: TextStyle(fontSize: 12, color: Colors.grey)),
              error: (_, __) => const Text('Tap for info', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Force Sync',
            onPressed: () async {
              if (_currentUserId != null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing...')));
                await ref.read(socialRepositoryProvider).refreshSync(_currentUserId!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupInfoScreen(groupId: widget.groupId)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const Gap(16),
                        const Text('No messages yet. Start the conversation!'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;
                    final showHeader = index == 0 || messages[index - 1].senderId != msg.senderId;
                    
                    return SwipeTo(
                      onRightSwipe: (details) {
                        setState(() {
                          _replyingTo = msg;
                        });
                      },
                      child: _MessageBubble(
                        message: msg, 
                        isMe: isMe,
                        showHeader: showHeader,
                        groupMemberCount: memberCount,
                        onReply: () {
                          setState(() {
                            _replyingTo = msg;
                          });
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          if (_showMentionList)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
              ),
              child: ListView.builder(
                itemCount: _mentionMatches.length,
                itemBuilder: (context, index) {
                  final member = _mentionMatches[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(member['name']![0])),
                    title: Text(member['name']!),
                    onTap: () => _insertMention(member),
                  );
                },
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${_replyingTo!.senderName}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _replyingTo!.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _replyingTo = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {}, // Attachments (future)
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final SocialChatMessage message;
  final bool isMe;
  final bool showHeader;
  final int groupMemberCount;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message, 
    required this.isMe,
    required this.showHeader,
    required this.groupMemberCount,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch real name if possible
    final nameFuture = ref.watch(socialRepositoryProvider).getMemberName(message.senderId);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showHeader && !isMe)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, top: 8),
            child: FutureBuilder<String>(
              future: nameFuture,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.replyToId != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.replyToSenderName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          message.replyToContent ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(context),
                      const Gap(4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe 
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7) 
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isMe) ...[
                            const Gap(4),
                            // Show checkmarks based on read status
                            if (!message.isSynced)
                              const SizedBox.shrink() // Offline/Sending: No icon
                            else
                              GestureDetector(
                                onTap: () => _showReadByList(context, ref, message.readBy),
                                child: message.readBy.length >= groupMemberCount
                                  ? const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent) // Double tick blue (Read by all)
                                  : Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)), // Single tick (Sent)
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showReadByList(BuildContext context, WidgetRef ref, List<String> readByIds) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Read by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            if (readByIds.isEmpty)
              const Text('No one yet.')
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: readByIds.length,
                  itemBuilder: (context, index) {
                    final userId = readByIds[index];
                    return FutureBuilder<String>(
                      future: ref.read(socialRepositoryProvider).getMemberName(userId),
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? 'Loading...';
                        return ListTile(
                          leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                          title: Text(name),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final style = TextStyle(
      color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
      fontSize: 15,
    );
    final mentionStyle = style.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline);

    List<InlineSpan> spans = [];
    final words = message.content.split(' ');
    
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('@') && word.length > 1) {
        spans.add(TextSpan(text: '$word ', style: mentionStyle));
      } else {
        spans.add(TextSpan(text: '$word ', style: style));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}
