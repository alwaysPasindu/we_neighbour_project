import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/chat_room.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User methods
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status.toString(),
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }

  Stream<ChatUser> userStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => ChatUser.fromMap(snapshot.data() ?? {}, snapshot.id));
  }

  Future<List<ChatUser>> getUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => ChatUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  // Chat room methods
  Future<String> createChatRoom(List<String> participantIds) async {
    try {
      // Check if a chat room already exists with these participants
      final existingRoom = await _firestore
          .collection('chatRooms')
          .where('participantIds', isEqualTo: participantIds)
          .get();

      if (existingRoom.docs.isNotEmpty) {
        return existingRoom.docs.first.id;
      }

      // Create a new chat room
      final docRef = await _firestore.collection('chatRooms').add({
        'participantIds': participantIds,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'lastMessageSenderId': '',
        'readStatus': {},
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      rethrow;
    }
  }

  Stream<List<ChatRoom>> getChatRoomsForUser(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Message methods
  Future<void> sendMessage(String roomId, ChatMessage message) async {
    try {
      // Add message to the messages subcollection
      await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .add(message.toMap());

      // Update the chat room with the last message info
      Map<String, bool> readStatus = {};
      for (String userId in (await _firestore.collection('chatRooms').doc(roomId).get())
          .data()?['participantIds'] ?? []) {
        readStatus[userId] = userId == message.senderId;
      }

      await _firestore.collection('chatRooms').doc(roomId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'readStatus': readStatus,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<ChatMessage>> getMessagesForRoom(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final roomDoc = await _firestore.collection('chatRooms').doc(roomId).get();
      Map<String, bool> readStatus = Map<String, bool>.from(roomDoc.data()?['readStatus'] ?? {});
      readStatus[userId] = true;

      await _firestore.collection('chatRooms').doc(roomId).update({
        'readStatus': readStatus,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }
}
