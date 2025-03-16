import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final AppUser receiver;

  const ChatScreen({Key? key, required this.receiver}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _controller = TextEditingController();
  String? userId;
  String? userName;
  String? chatRoomId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      DocumentSnapshot userDoc = await _firestore
          .collection('apartments')
          .doc('Dehiwala_Dreams')
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'Unknown User';
        });
      }
      initializeChatRoom();
    }
  }

  void initializeChatRoom() async {
    final participants = [userId, widget.receiver.id]..sort();
    chatRoomId = participants.join('_');

    // Check if chat room exists, if not create it
    final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
    final chatRoomDoc = await chatRoomRef.get();
    if (!chatRoomDoc.exists) {
      await chatRoomRef.set({
        'apartmentName': 'Dehiwala_Dreams',
        'participants': participants,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void sendMessage(String messageText) async {
    if (messageText.trim().isEmpty || userId == null || chatRoomId == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': messageText.trim(),
        'senderId': userId,
        'senderName': userName ?? userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chats').doc(chatRoomId).update({
        'lastMessage': messageText.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || chatRoomId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.receiver.name[0],
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            SizedBox(width: 10),
            Text(widget.receiver.name),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Start chatting!'));
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final messageText = messageData['text'] ?? '';
                  final messageSender = messageData['senderId'] ?? '';
                  final messageSenderName = messageData['senderName'] ?? messageSender;
                  final messageWidget = MessageBubble(
                    text: messageText,
                    sender: messageSenderName,
                    isMe: messageSender == userId,
                  );
                  messageWidgets.add(messageWidget);
                }
                return ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: messageWidgets,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Material(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(25),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendMessage(_controller.text),
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