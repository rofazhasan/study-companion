import 'package:isar/isar.dart';

part 'social_models.g.dart';

@collection
class StudyGroup {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String groupId; // Firestore ID

  late String name;
  late String topic;
  
  @Index()
  late String joinCode;

  late int memberCount;
  late List<String> memberIds;
  
  // Admin & Moderation
  String creatorId = '';
  List<String> adminIds = [];
  List<String> bannedIds = [];

  late DateTime createdAt;

  // Local sync status
  bool isSynced = true;
}

@collection
class SocialChatMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String messageId; // Firestore ID

  @Index()
  late String groupId;

  late String senderId;
  late String senderName;
  late String content;
  late DateTime timestamp;

  bool isMe = false;
  
  // Rich Chat Features
  String? replyToId;
  String? replyToContent;
  String? replyToSenderName;
  List<String> mentions = [];

  // For ephemeral logic
  late List<String> readBy;

  // Local sync status
  bool isSynced = true;
}
