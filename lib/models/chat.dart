import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants; // For one-to-one chats
  final List<String> members; // For group chats
  final bool isGroup;
  final String? groupName;
  final String? lastMessage;
  final Timestamp? timestamp;
  final String? resourceId;

  Chat({
    required this.id,
    required this.participants,
    required this.members,
    required this.isGroup,
    this.groupName,
    this.lastMessage,
    this.timestamp,
    this.resourceId,
  });

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      members: List<String>.from(data['members'] ?? []),
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      lastMessage: data['lastMessage'],
      timestamp: data['timestamp'] as Timestamp?,
      resourceId: data['resourceId'],
    );
  }
}