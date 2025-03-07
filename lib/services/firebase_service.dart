// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId; // Pass chat ID from MongoDB or wherever
//   ChatScreen({required this.chatId});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _database = FirebaseDatabase.instance.ref();
//   final _controller = TextEditingController();

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       _database.child('chats').child(widget.chatId).child('messages').push().set({
//         'sender_id': 'user1', // Replace with actual user ID from MongoDB
//         'text': _controller.text,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       });
//       _controller.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _database.child('chats').child(widget.chatId).child('messages').onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//                 final messages = Map<String, dynamic>.from(
//                     snapshot.data!.snapshot.value as Map? ?? {});
//                 final messageList = messages.entries.toList()
//                   ..sort((a, b) => (b.value['timestamp']).compareTo(a.value['timestamp']));
//                 return ListView.builder(
//                   reverse: true, // Newest messages at the bottom
//                   itemCount: messageList.length,
//                   itemBuilder: (context, index) {
//                     final message = messageList[index].value;
//                     bool isMe = message['sender_id'] == 'user1'; // Replace with actual logic
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blueAccent : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Text(
//                           message['text'],
//                           style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }