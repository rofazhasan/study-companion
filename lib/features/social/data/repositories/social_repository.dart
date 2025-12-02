import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/isar_service.dart';
import '../../../../core/providers/startup_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../models/social_models.dart';
import '../models/leaderboard_entry.dart';

part 'social_repository.g.dart';

@Riverpod(keepAlive: true)
SocialRepository socialRepository(SocialRepositoryRef ref) {
  return SocialRepository(ref.read(isarServiceProvider));
}

class SocialRepository {
  final IsarService _isarService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  SocialRepository(this._isarService);

  // Active chat tracking for notification suppression
  String? _activeGroupId;
  
  void setActiveChat(String? groupId) {
    _activeGroupId = groupId;
  }

  // Message sync subscriptions
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  // --- Groups ---

  Future<List<StudyGroup>> getGroups() async {
    return await _isarService.db.studyGroups.where().findAll();
  }

  Stream<List<StudyGroup>> watchGroups() {
    return _isarService.db.studyGroups.where().watch(fireImmediately: true);
  }

  Future<void> createGroup(String name, String topic, String userId) async {
    final joinCode = _generateJoinCode();
    final groupId = _uuid.v4();
    final now = DateTime.now();

    final group = StudyGroup()
      ..groupId = groupId
      ..name = name
      ..topic = topic
      ..joinCode = joinCode
      ..memberCount = 1
      ..memberIds = [userId]
      ..creatorId = userId
      ..adminIds = [userId]
      ..bannedIds = []
      ..createdAt = now
      ..isSynced = true; // Assume synced initially as we write to both

    // 1. Save to Isar
    await _isarService.db.writeTxn(() async {
      await _isarService.db.studyGroups.put(group);
    });

    // 2. Save to Firestore
    try {

      await _firestore.collection('groups').doc(groupId).set({
        'id': groupId,
        'name': name,
        'topic': topic,
        'joinCode': joinCode,
        'memberCount': 1,
        'memberIds': [userId],
        'creatorId': userId,
        'adminIds': [userId],
        'bannedIds': [],
        'createdAt': now.toIso8601String(),
      });
    } catch (e) {
      // Mark as unsynced if offline (TODO: Implement background sync queue)
      group.isSynced = false;
      await _isarService.db.writeTxn(() async {
        await _isarService.db.studyGroups.put(group);
      });
      // rethrow; // Don't rethrow if we handled it by saving locally
    }
  }

  Future<void> joinGroup(String joinCode, String userId) async {

    // 1. Query Firestore for code
    final query = await _firestore
        .collection('groups')
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();



    if (query.docs.isEmpty) {
      throw Exception('Invalid join code');
    }

    final doc = query.docs.first;
    final data = doc.data();
    final List<dynamic> members = data['memberIds'] ?? [];
    final List<dynamic> bannedIds = data['bannedIds'] ?? [];

    if (bannedIds.contains(userId)) {
      throw Exception('You are banned from this group');
    }

    if (members.contains(userId)) {
      // Already a member on server, but maybe missing locally?
      // Restore it!
      final group = StudyGroup()
        ..groupId = data['id']
        ..name = data['name']
        ..topic = data['topic']
        ..joinCode = data['joinCode']
        ..memberCount = data['memberCount'] as int
        ..memberIds = List<String>.from(members)
        ..creatorId = data['creatorId'] ?? (members.isNotEmpty ? members[0] : userId)
        ..adminIds = List<String>.from(data['adminIds'] ?? [])
        ..bannedIds = List<String>.from(data['bannedIds'] ?? [])
        ..createdAt = DateTime.parse(data['createdAt'])
        ..isSynced = true;

      await _isarService.db.writeTxn(() async {
        await _isarService.db.studyGroups.put(group);
      });
      
      // Force sync to be sure
      refreshSync(userId);
      
      throw Exception('Group restored! You were already a member.');
    }

    // 2. Add user to Firestore group
    await _firestore.collection('groups').doc(doc.id).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });

    // 3. Save to local Isar
    final updatedMembers = List<String>.from(members)..add(userId);
    final group = StudyGroup()
      ..groupId = data['id']
      ..name = data['name']
      ..topic = data['topic']
      ..joinCode = data['joinCode']
      ..memberCount = (data['memberCount'] as int) + 1
      ..memberIds = updatedMembers
      ..creatorId = data['creatorId'] ?? data['memberIds'][0] // Fallback for old groups
      ..adminIds = List<String>.from(data['adminIds'] ?? [data['memberIds'][0]])
      ..bannedIds = List<String>.from(data['bannedIds'] ?? [])
      ..createdAt = DateTime.parse(data['createdAt'])
      ..isSynced = true;

    await _isarService.db.writeTxn(() async {
      await _isarService.db.studyGroups.put(group);
    });

    // 4. Force refresh sync to pick up the new group immediately
    refreshSync(userId);
  }

  Future<void> refreshSync(String userId) async {
    print('DEBUG: Force refreshing sync for user $userId');
    stopGroupSync();
    startGroupSync(userId);
  }

  StreamSubscription<QuerySnapshot>? _groupSubscription;

  void startGroupSync(String userId) {

    _groupSubscription?.cancel();
    
    try {
      print('DEBUG: Starting group sync for user $userId');
      _groupSubscription = _firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .listen((snapshot) async {
      
      final serverGroupIds = <String>{};
      
      // Sync messages for each group
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final groupId = data['id'] as String;
        final groupName = data['name'] as String;
        serverGroupIds.add(groupId);

        if (!_messageSubscriptions.containsKey(groupId)) {
          print('Starting message sync for group: $groupName ($groupId)');
          _messageSubscriptions[groupId] = syncMessages(groupId, userId, groupName).listen((_) {}, onError: (e) {
            print('Error syncing messages for group $groupId: $e');
          });
        }
      }

      // Cleanup subscriptions for removed groups
      final idsToRemove = _messageSubscriptions.keys.where((id) => !serverGroupIds.contains(id)).toList();
      for (final id in idsToRemove) {
        await _messageSubscriptions[id]?.cancel();
        _messageSubscriptions.remove(id);
      }
      
      await _isarService.db.writeTxn(() async {
        // 1. Update/Insert groups from server
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final groupId = data['id'] as String;
          serverGroupIds.add(groupId);

          final group = StudyGroup()
            ..groupId = groupId
            ..name = data['name']
            ..topic = data['topic']
            ..joinCode = data['joinCode']
            ..memberCount = data['memberCount'] as int
            ..memberIds = List<String>.from(data['memberIds'])
            ..creatorId = data['creatorId'] ?? data['memberIds'][0]
            ..adminIds = List<String>.from(data['adminIds'] ?? [data['memberIds'][0]])
            ..bannedIds = List<String>.from(data['bannedIds'] ?? [])
            ..createdAt = DateTime.parse(data['createdAt'])
            ..isSynced = true;
            
          await _isarService.db.studyGroups.put(group);
        }

        // 2. Delete local groups that are no longer on server (kicked/left)
        // We fetch all local groups first
        final localGroups = await _isarService.db.studyGroups.where().findAll();
        for (final localGroup in localGroups) {
          if (!serverGroupIds.contains(localGroup.groupId)) {

            // Delete group
            await _isarService.db.studyGroups.delete(localGroup.id);
            // Delete messages for this group
            await _isarService.db.socialChatMessages.filter().groupIdEqualTo(localGroup.groupId).deleteAll();
          }
        }
      });
      }, onError: (e) {
        print('Error in group sync stream: $e');
      });
    } catch (e) {
      print('Error setting up group sync: $e');
    }
  }

  void stopGroupSync() {
    _groupSubscription?.cancel();
    _groupSubscription = null;
    
    // Cancel all message subscriptions
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();
  }

  String _generateJoinCode() {
    final rng = Random();
    return (1000 + rng.nextInt(9000)).toString();
  }

  // --- Chat ---

  Stream<List<SocialChatMessage>> watchMessages(String groupId) {
    return _isarService.db.socialChatMessages
        .filter()
        .groupIdEqualTo(groupId)
        .sortByTimestamp()
        .watch(fireImmediately: true);
  }

  Future<void> sendMessage(String groupId, String senderId, String senderName, String content, {String? replyToId, String? replyToContent, String? replyToSenderName, List<String>? mentions}) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = SocialChatMessage()
      ..messageId = messageId
      ..groupId = groupId
      ..senderId = senderId
      ..senderName = senderName
      ..content = content
      ..timestamp = now
      ..replyToId = replyToId
      ..replyToContent = replyToContent
      ..replyToSenderName = replyToSenderName
      ..mentions = mentions ?? []
      ..isMe = true
      ..readBy = [senderId]
      ..isSynced = false;

    // 1. Save locally immediately
    await _isarService.db.writeTxn(() async {
      await _isarService.db.socialChatMessages.put(message);
    });

    // 2. Send to Firestore
    try {
      await _firestore.collection('groups').doc(groupId).collection('messages').doc(messageId).set({
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': now.toIso8601String(),
        'replyToId': replyToId,
        'replyToContent': replyToContent,
        'replyToSenderName': replyToSenderName,
        'mentions': mentions ?? [],
        'readBy': [senderId],
      });

      // Mark as synced
      message.isSynced = true;
      await _isarService.db.writeTxn(() async {
        await _isarService.db.socialChatMessages.put(message);
      });
    } catch (e) {
      // Keep as unsynced, will retry later (TODO: Sync worker)
      print('Error sending message: $e');
    }
  }

  // Sync Logic: Listen to Firestore and update local DB
  Stream<void> syncMessages(String groupId, String userId, String groupName) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .snapshots()
        .asyncMap((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final messageId = data['id'] as String;
          final senderId = data['senderId'] as String;
          
          // Skip if we already have it and it's ours (avoid duplicates from local optimistic update)
          if (senderId == userId) {
             // Ensure it's marked synced
             final localMsg = await _isarService.db.socialChatMessages.filter().messageIdEqualTo(messageId).findFirst();
             if (localMsg != null && !localMsg.isSynced) {
               localMsg.isSynced = true;
               await _isarService.db.writeTxn(() => _isarService.db.socialChatMessages.put(localMsg));
             }
             continue;
          }

          // Check if exists
          final existing = await _isarService.db.socialChatMessages.filter().messageIdEqualTo(messageId).findFirst();
          if (existing != null) continue;

          // Save new message
          final newMessage = SocialChatMessage()
            ..messageId = messageId
            ..groupId = groupId
            ..senderId = senderId
            ..senderName = data['senderName'] as String
            ..content = data['content'] as String
            ..timestamp = DateTime.parse(data['timestamp'] as String)
            ..replyToId = data['replyToId'] as String?
            ..replyToContent = data['replyToContent'] as String?
            ..replyToSenderName = data['replyToSenderName'] as String?
            ..mentions = List<String>.from(data['mentions'] ?? [])
            ..isMe = false
            ..readBy = List<String>.from(data['readBy'] ?? [])
            ..isSynced = true;

          await _isarService.db.writeTxn(() async {
            await _isarService.db.socialChatMessages.put(newMessage);
          });

          // Trigger Notification if not me and not in active chat
          if (senderId != userId && !newMessage.readBy.contains(userId) && _activeGroupId != groupId) {
             NotificationService().showMessageNotification(
               id: messageId, 
               title: '$groupName: ${data['senderName'] ?? 'Unknown'}', 
               body: data['content'] ?? 'Sent a message', 
               groupId: groupId
             );
          }
        }
        
        if (change.type == DocumentChangeType.modified) {
           final data = change.doc.data();
           if (data == null) continue;
           
           final messageId = data['id'] as String;
           final readBy = List<String>.from(data['readBy'] ?? []);
           
           // Update local message read status
           final localMsg = await _isarService.db.socialChatMessages.filter().messageIdEqualTo(messageId).findFirst();
           if (localMsg != null) {
             localMsg.readBy = readBy;
             await _isarService.db.writeTxn(() => _isarService.db.socialChatMessages.put(localMsg));
           }

           // Check for deletion condition (Ephemeral logic part 2)
           // Optimization: Use memberCount from local group if available to avoid Firestore read
           // But for safety, we'll read the group doc occasionally or rely on the fact that we are syncing groups too.
           
           try {
             final groupDoc = await _firestore.collection('groups').doc(groupId).get();
             if (groupDoc.exists) {
               final memberCount = groupDoc.data()?['memberCount'] as int? ?? 0;
               final allMembers = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
               
               // If all members read it, delete from Firestore
               // We check both count and explicit IDs to be safe
               if (readBy.length >= memberCount && readBy.length >= allMembers.length) {
                  print('DEBUG: Deleting message $messageId as all ${readBy.length} members read it.');
                  await _firestore.collection('groups').doc(groupId).collection('messages').doc(change.doc.id).delete();
               }
             }
           } catch (e) {
             print('Error checking deletion condition: $e');
           }
        }
      }
    });
  }
  // --- Admin & Moderation ---

  Future<void> updateGroup(String groupId, String name, String topic) async {
    await _firestore.collection('groups').doc(groupId).update({
      'name': name,
      'topic': topic,
    });
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'adminIds': FieldValue.arrayRemove([userId]),
      'memberCount': FieldValue.increment(-1),
    });
  }

  Future<void> promoteAdmin(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'adminIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> demoteAdmin(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'adminIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> kickMember(String groupId, String userId) async {
    // Kicking removes them from members and admins, effectively "deleting" their access
    // Their messages remain (unless cleared by admin), but they can't see them anymore
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'adminIds': FieldValue.arrayRemove([userId]), 
      'memberCount': FieldValue.increment(-1),
    });
  }

  Future<void> banMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'adminIds': FieldValue.arrayRemove([userId]),
      'bannedIds': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(-1),
    });
  }

  Future<void> unbanMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'bannedIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> markAllSeen(String groupId) async {
    // Admin feature: Delete all messages from Firestore to save space
    // They will remain in local Isar DB for users who have already synced
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('groups').doc(groupId).collection('messages').get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  Future<void> markMessagesAsRead(String groupId, String userId) async {
    final unreadMessages = await _isarService.db.socialChatMessages
        .filter()
        .groupIdEqualTo(groupId)
        .not()
        .readByElementEqualTo(userId)
        .findAll();

    if (unreadMessages.isEmpty) return;

    final batch = _firestore.batch();
    
    for (final msg in unreadMessages) {
      // Update local
      msg.readBy = [...msg.readBy, userId];
      
      // Update Firestore
      final ref = _firestore.collection('groups').doc(groupId).collection('messages').doc(msg.messageId);
      batch.update(ref, {
        'readBy': FieldValue.arrayUnion([userId])
      });
    }
    
    await _isarService.db.writeTxn(() async {
      await _isarService.db.socialChatMessages.putAll(unreadMessages);
    });

    await batch.commit();
  }

  Stream<int> watchUnreadCount(String groupId, String userId) {
    return _isarService.db.socialChatMessages
        .filter()
        .groupIdEqualTo(groupId)
        .not()
        .readByElementEqualTo(userId)
        .watch(fireImmediately: true)
        .map((messages) => messages.length);
  }

  Future<String> getMemberName(String userId) async {

    // Try to find in local groups first (if they are a member of a group we have)
    // This is a simple optimization. Ideally we'd have a separate Users collection synced.
    // For now, we'll fetch from Firestore if needed.
    
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final name = data?['name'] ?? 'Unknown User';
        return name;
      }
    } catch (e) {
      // Error fetching member name, return default
    }
    return 'Unknown User';
  }

  // --- Typing Indicators ---

  Future<void> sendTypingStatus(String groupId, String userId, String userName, bool isTyping) async {
    try {
      final docRef = _firestore.collection('groups').doc(groupId).collection('typing').doc(userId);
      if (isTyping) {
        await docRef.set({
          'userName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {

    }
  }

  Stream<List<String>> watchTypingStatus(String groupId, String currentUserId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId) // Don't show own typing status
          .map((doc) => doc.data()['userName'] as String)
          .toList();
    });
  }

  // --- Mentions ---

  Future<List<Map<String, String>>> getGroupMembers(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return [];
      
      final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
      if (memberIds.isEmpty) return [];

      // In a real app, you might want to batch this or have a denormalized members subcollection
      // For now, we'll fetch user docs. Limit to 10 for safety in this demo if needed, but let's try all.
      
      // Firestore 'in' query is limited to 10. So we'll just fetch individually for now or use a loop.
      // Optimization: Check local cache or just fetch.
      
      List<Map<String, String>> members = [];
      for (final id in memberIds) {
        final name = await getMemberName(id);
        members.add({'id': id, 'name': name});
      }
      return members;
    } catch (e) {

      return [];
    }
  }

  Future<List<Map<String, String>>> getBannedMembers(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return [];
      
      final bannedIds = List<String>.from(groupDoc.data()?['bannedIds'] ?? []);
      if (bannedIds.isEmpty) return [];

      List<Map<String, String>> banned = [];
      for (final id in bannedIds) {
        final name = await getMemberName(id);
        banned.add({'id': id, 'name': name});
      }
      return banned;
    } catch (e) {

      return [];
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value.data();
        return LeaderboardEntry(
          rank: index + 1,
          username: data['name'] ?? 'Unknown',
          userId: entry.value.id,
          streak: data['streak'] ?? 0,
          weeklyHours: ((data['weeklyStudyMinutes'] ?? 0) as num).toDouble() / 60.0,
          score: data['score'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }
}
