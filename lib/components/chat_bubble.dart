import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByCurrentUser;
  final Timestamp timestamp;

  MessageBubble({
    Key? key,
    required this.message,
    required this.isSentByCurrentUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSentByCurrentUser ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              message,
              style: TextStyle(
                color: isSentByCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            ChatService().formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
