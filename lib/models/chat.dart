import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat (one-on-one or group) in the application.
class Chat {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isGroup;
  final String? name; // Added for group chat names

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.isGroup = false,
    this.name, // Optional for groups
  });

  factory Chat.fromFirestore(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      isGroup: data['isGroup'] ?? false,
      name: data['name'], // Fetch name for groups
    );
  }
}