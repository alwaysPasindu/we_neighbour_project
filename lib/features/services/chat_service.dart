import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send Message
  Future<void> sendMessage(String receiverId, String message, {String messageType = 'text'}) async {
    try {
      final String currentUserId = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      // Construct chat room ID from user IDs (sorted lexicographically)
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Create a new message
      Map<String, dynamic> messageData = {
        'senderId': currentUserId,
        'senderEmail': currentUserEmail,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'messageType': messageType, // Added message type
      };

      // Add message to the database
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      print("Error sending message: $e");
      // Handle the error appropriately
    }
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Construct chat room ID from user IDs (sorted lexicographically)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Format Timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime); // Format as HH:mm AM/PM
  }
}