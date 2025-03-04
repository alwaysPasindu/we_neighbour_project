//  import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// // import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import '../services/chat_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:record/record.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:path_provider/path_provider.dart';

// class ChatInput extends StatefulWidget {
//   final String receiverId;
//   const ChatInput({Key? key, required this.receiverId}) : super(key: key);

//   @override
//   State createState() => _ChatInputState();
// }

// class _ChatInputState extends State<ChatInput> {
//   final TextEditingController _messageController = TextEditingController();
//   final ImagePicker _imagePicker = ImagePicker();
//   final ChatService _chatService = ChatService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isRecording = false;
//   String? _recordingPath;

//   Future<void> sendMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       await _chatService.sendMessage(widget.receiverId, _messageController.text);
//       _messageController.clear();
//     }
//   }

//   Future<void> sendImage() async {
//     final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;

//     // Upload image to Firebase Storage
//     // String imageName = DateTime.now().millisecondsSinceEpoch.toString();
//     // firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
//     //     .ref()
//     //     .child('chat_images')
//     //     .child(_auth.currentUser!.uid)
//     //     .child(imageName);

//     // File imageFile = File(image.path);
//     // await storageRef.putFile(imageFile);

//     // // Get the image URL
//     // String imageUrl = await storageRef.getDownloadURL();

//     // Send the image URL as a message
//   //   await _chatService.sendMessage(widget.receiverId, imageUrl, messageType: 'image');
//   // }

//   Future<void> startRecording() async {
//     final directory = await getTemporaryDirectory();
//     _recordingPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

//     try {
//       if (await _audioRecorder.hasPermission()) {
//         await _audioRecorder.start(const RecordConfig(), path: _recordingPath!);
//         setState(() => _isRecording = true);
//       } else {
//         print("Audio Recording: Permission Denied");
//       }
//     } catch (e) {
//       print("Error starting recording: $e");
//     }
//   }

//   Future<void> stopRecording() async {
//     try {
//       String? path = await _audioRecorder.stop();
//       setState(() => _isRecording = false);

//       if (path != null) {
//         File audioFile = File(path);

//         String audioName = DateTime.now().millisecondsSinceEpoch.toString();
//         firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
//             .ref()
//             .child('chat_audio')
//             .child(_auth.currentUser!.uid)
//             .child(audioName);

//         await storageRef.putFile(audioFile);
//         String audioUrl = await storageRef.getDownloadURL();

//         await _chatService.sendMessage(widget.receiverId, audioUrl, messageType: 'voice');
//       }
//     } catch (e) {
//       print("Error stopping recording: $e");
//     }
//   }

//   Future<void> playRecording(String audioUrl) async {
//     try {
//       await _audioPlayer.play(UrlSource(audioUrl));
//     } catch (e) {
//       print("Error playing recording: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: 'Enter message...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: sendImage,
//                   iconSize: 28,
//                   color: Colors.blue,
//                 ),
//                 IconButton(
//                   icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//                   onPressed: _isRecording ? stopRecording : startRecording,
//                   iconSize: 28,
//                   color: Colors.blue,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: sendMessage,
//                   iconSize: 28,
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
