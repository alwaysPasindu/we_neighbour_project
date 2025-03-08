import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat message in the application.
class Message {
  final String id; // Unique identifier for the message (from Firestore)
  final String senderId; // ID of the user who sent the message
  final String content; // The text content of the message
  final DateTime timestamp; // When the message was sent
  final bool isReply; // Indicates if this message is a reply to another message or resource
  final String? replyTo; // The ID of the resource or message being replied to (e.g., resource ID)

  /// Constructs a [Message] instance.
  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isReply = false,
    this.replyTo,
  });

  /// Creates a [Message] from Firestore data.
  factory Message.fromFirestore(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isReply: data['isReply'] as bool? ?? false,
      replyTo: data['replyTo'] as String?,
    );
  }

  /// Converts a [Message] to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isReply': isReply,
      'replyTo': replyTo,
    };
  }
}