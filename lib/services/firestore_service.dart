import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Use relative imports
import '../models/message.dart';
import '../models/profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  CollectionReference get _presenceCollection => _firestore.collection('presence');

  // Get user profile
  Future<Profile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return Profile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Create or update user profile
  Future<void> createOrUpdateUserProfile({
    required String userId,
    required String username,
    String? avatarUrl,
    String? website,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'id': userId,
        'username': username,
        'avatar_url': avatarUrl,
        'website': website,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get all users (including MongoDB users)
  Stream<List<Profile>> getAllUsers() {
    debugPrint('Getting all users from Firestore');
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return _usersCollection
        .where('id', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => Profile.fromFirestore(doc)).toList();
      debugPrint('Found ${users.length} users in Firestore');
      return users;
    });
  }

  // Get MongoDB users specifically
  Stream<List<Profile>> getMongoDBUsers() {
    debugPrint('Getting MongoDB users from Firestore');
    return _usersCollection
        .where('source', isEqualTo: 'mongodb')
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => Profile.fromFirestore(doc)).toList();
      debugPrint('Found ${users.length} MongoDB users in Firestore');
      return users;
    });
  }

  // Add a method to get users by apartment
  Stream<List<Profile>> getUsersByApartment(String apartmentId) {
    debugPrint('Getting users for apartment: $apartmentId');
    return _usersCollection
        .where('apartmentId', isEqualTo: apartmentId)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => Profile.fromFirestore(doc)).toList();
      debugPrint('Found ${users.length} users for apartment $apartmentId');
      return users;
    });
  }

  // Update user presence
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      await _presenceCollection.doc(userId).set({
        'user_id': userId,
        'status': isOnline ? 'online' : 'offline',
        'last_seen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently handle presence update errors
      debugPrint('Error updating presence: $e');
    }
  }

  // Get user presence
  Stream<Map<String, dynamic>> getUserPresence(String userId) {
    return _presenceCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return {'status': 'offline', 'last_seen': null};
      }
    });
  }

  // Get all user presences
  Stream<List<Map<String, dynamic>>> getAllUserPresences() {
    return _presenceCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Send message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Create a unique chat room ID by sorting the user IDs
      final List<String> userIds = [senderId, receiverId];
      userIds.sort(); // Sort to ensure the same room ID regardless of who initiates
      final chatRoomId = userIds.join('_');

      await _messagesCollection.add({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'chat_room_id': chatRoomId,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages for a chat room
  Stream<List<Message>> getMessages(String userId1, String userId2) {
    // Create a unique chat room ID by sorting the user IDs
    final List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort to ensure the same room ID regardless of who initiates
    final chatRoomId = userIds.join('_');

    return _messagesCollection
        .where('chat_room_id', isEqualTo: chatRoomId)
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }
}

