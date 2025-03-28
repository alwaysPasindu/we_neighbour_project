import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final bool isGroup;
  final String? name;
  final String? lastMessage;
  final Timestamp? timestamp;
  final List<String>? members;

  Chat({
    required this.id,
    required this.participants,
    required this.isGroup,
    this.name,
    this.lastMessage,
    this.timestamp,
    this.members,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> data) {
    return Chat(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      isGroup: data['isGroup'] ?? false,
      name: data['name'],
      lastMessage: data['lastMessage'],
      timestamp: data['timestamp'],
      members: data['members'] != null ? List<String>.from(data['members']) : null,
    );
  }

  get unreadCount => null;
}
