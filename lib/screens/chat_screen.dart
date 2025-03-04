// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/chat_service.dart';
// import '../components/chat_bubble.dart';
// import '../components/chat_input.dart';

// class ChatScreen extends StatelessWidget {
//   final String receiverId;
//   final String receiverEmail;

//   ChatScreen({Key? key, required this.receiverId, required this.receiverEmail})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(receiverEmail),
//       ),
//       body: Column(
//         children: [
//           // Message List
//           Expanded(
//             child: _buildMessageList(),
//           ),

//           // User Input
//           ChatInput(receiverId: receiverId),
//           const SizedBox(height: 10)
//         ],
//       ),
//     );
//   }

//   // Build Message List
//   Widget _buildMessageList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: ChatService().getMessages(
//           FirebaseAuth.instance.currentUser!.uid, receiverId),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Something went wrong: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text('Loading...');
//         }

//         return ListView(
//           children: snapshot.data!.docs
//               .map((document) => _buildMessageItem(document))
//               .toList(),
//         );
//       },
//     );
//   }

//   // Build Message Item
//   Widget _buildMessageItem(DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//     bool isSentByCurrentUser = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;

//     return MessageBubble(
//       message: data['message'],
//       isSentByCurrentUser: isSentByCurrentUser,
//       timestamp: (data['timestamp'] as Timestamp),
//     );
//   }
// }
