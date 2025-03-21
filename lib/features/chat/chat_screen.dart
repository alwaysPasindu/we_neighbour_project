import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/providers/chat_provider.dart';

// Assuming a Message model
class Message {
  final String id;
  final String senderId;
  final String content;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isGroup;
  final String? resourceId;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.isGroup = false,
    this.resourceId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Stream<List<Message>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromDocument(doc)).toList());
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .sendMessage(widget.chatId, _messageController.text.trim());
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .deleteMessage(widget.chatId, messageId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = chatProvider.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroup ? 'Group Chat' : 'One-on-One Chat'),
        actions: widget.resourceId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Resource ID: ${widget.resourceId}')),
                    );
                  },
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text(message.senderId),
                      trailing: isMe
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteMessage(message.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}