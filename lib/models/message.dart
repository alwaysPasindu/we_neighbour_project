import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String chatRoomId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.chatRoomId,
    required this.createdAt,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['sender_id'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      content: data['content'] ?? '',
      chatRoomId: data['chat_room_id'] ?? '',
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'chat_room_id': chatRoomId,
      'created_at': createdAt,
    };
  }
}

