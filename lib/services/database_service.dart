import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference messageCollection = FirebaseFirestore.instance.collection('messages');

  Future<void> updateUserData(String email) async {
    return await userCollection.doc(uid).set({
      'email': email,
      'uid': uid,
    });
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return messageCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> sendMessage(String chatId, String text) async {
    return await messageCollection.add({
      'senderId': uid,
      'text': text,
      'chatId': chatId,
      'timestamp': DateTime.now(),
    });
  }
}