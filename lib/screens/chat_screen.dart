import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../utils/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  final AppUser currentUser;
  final AppUser receiver;

  const ChatScreen({super.key, required this.currentUser, required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late DatabaseReference _databaseRef;

  @override
  void initState() {
    super.initState();
    // Create a unique chat room ID for the two users (sorted to avoid duplicates)
    final chatRoomId = [widget.currentUser.id, widget.receiver.id]..sort();
    _databaseRef = FirebaseDatabase.instance.ref('messages/${chatRoomId.join("_")}');

    // Listen for new messages
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final messages = data.entries
            .map((entry) => Message.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessageRef = _databaseRef.push();
    final message = Message(
      id: newMessageRef.key!,
      senderId: widget.currentUser.id,
      receiverId: widget.receiver.id,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    newMessageRef.set(message.toJson());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver.email),
        backgroundColor: const Color(0xFF075E54),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == widget.currentUser.id;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD9FDD3) : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(message.content),
                        const SizedBox(height: 4.0),
                        Text(
                          formatTimestamp(message.timestamp),
                          style: const TextStyle(fontSize: 10.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
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
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: const Color(0xFF075E54),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}