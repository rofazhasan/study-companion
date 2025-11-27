import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../ai_chat/presentation/providers/chat_provider.dart';
import '../../../ai_chat/data/models/chat_message.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';

class ReflectionSheet extends ConsumerStatefulWidget {
  const ReflectionSheet({super.key});

  @override
  ConsumerState<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends ConsumerState<ReflectionSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  List<ChatMessage> _localMessages = []; // Temporary session messages

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndStart();
    });
  }

  Future<void> _checkConnectivityAndStart() async {
    final isOnline = await ref.read(connectivityNotifierProvider.future);
    if (!isOnline) {
      if (mounted) {
        setState(() {
          _localMessages.add(ChatMessage()
            ..role = 'ai'
            ..content = '🌐 Evening Reflection is not available offline.\n\nThis feature requires an internet connection to provide personalized reflections. Please connect to the internet and try again.'
            ..timestamp = DateTime.now());
        });
      }
    } else {
      _startReflection();
    }
  }

  Future<void> _startReflection() async {
    setState(() => _isTyping = true);
    
    // Simulate AI thinking
    await Future.delayed(const Duration(seconds: 1));
    
    final initialMsg = ChatMessage()
      ..role = 'ai'
      ..content = "Good evening! 🌙\n\nI see you've wrapped up your day. How did your study sessions go? Did you accomplish your goals?"
      ..timestamp = DateTime.now();
      
    setState(() {
      _localMessages.add(initialMsg);
      _isTyping = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage()
      ..role = 'user'
      ..content = text
      ..timestamp = DateTime.now();

    setState(() {
      _localMessages.add(userMsg);
      _controller.clear();
      _isTyping = true;
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      
      final analyticsAsync = ref.read(analyticsNotifierProvider);
      String contextInfo = "";
      
      if (analyticsAsync.hasValue) {
        final data = analyticsAsync.value!;
        final totalFocus = data['totalFocusToday'] as int;
        final sessions = (data['sessions'] as List).length;
        final duration = Duration(seconds: totalFocus);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        
        contextInfo = '''
Context:
- Total Focus Time Today: ${hours}h ${minutes}m
- Total Sessions Completed: $sessions
''';
      }

      // Context for reflection
      final prompt = '''
You are a supportive study coach conducting an evening reflection.
The student just finished their day.
$contextInfo
Goal: Help them reflect on wins, learn from challenges, and plan for tomorrow.
Be concise, encouraging, and ask one follow-up question at a time.

Student: $text
Coach:
''';

      final aiMsg = ChatMessage()
        ..role = 'ai'
        ..content = ''
        ..timestamp = DateTime.now();
        
      setState(() => _localMessages.add(aiMsg));

      final stream = aiService.generateResponse(prompt);
      
      await for (final chunk in stream) {
        setState(() {
          aiMsg.content += chunk;
        });
      }
    } catch (e) {
      setState(() {
        _localMessages.add(ChatMessage()..role = 'ai'..content = "I'm having trouble connecting to the AI brain right now. But don't let that stop you—great job today!");
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.nightlight_round, color: Colors.indigo),
                const Gap(8),
                Text(
                  'Evening Reflection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _localMessages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _localMessages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.indigo,
                          child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                        ),
                        Gap(8),
                        Text('Thinking...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                final msg = _localMessages[index];
                final isUser = msg.role == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : null,
                        bottomLeft: !isUser ? Radius.zero : null,
                      ),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: isUser 
                            ? Theme.of(context).colorScheme.onPrimary 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Input Area
          Padding(
            padding: EdgeInsets.only(
              left: 16, 
              right: 16, 
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Type your reflection...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
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
          ),
        ],
      ),
    );
  }
}
