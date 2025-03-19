import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart'; // Contains Chat
import '../models/message.dart' as message_model; // Prefix for Message

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;

  ChatProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');
    }
    notifyListeners();
  }

  // Add this method to refresh user data after login
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  String? get currentUserId => _currentUserId;

  Stream<List<Chat>> getChats() {
    if (_currentUserId == null) return const Stream.empty();
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chat.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<Chat>> getGroups() {
    if (_currentUserId == null) return const Stream.empty();
    return _firestore
        .collection('groups')
        .where('members', arrayContains: _currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chat.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<message_model.Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => message_model.Message.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> sendMessage(String chatId, String content, {String? replyTo}) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection('chats/$chatId/messages').add(
      message_model.Message(
        id: '', // Firestore will generate this
        senderId: _currentUserId!,
        content: content,
        timestamp: DateTime.now(),
        isReply: replyTo != null,
        replyTo: replyTo,
      ).toFirestore(),
    );

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createGroup(String name, List<String> members) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    final groupRef = await _firestore.collection('groups').add({
      'name': name,
      'members': [_currentUserId, ...members],
      'timestamp': FieldValue.serverTimestamp(),
      'isGroup': true,
    });
    await sendMessage(groupRef.id, 'Group created!', replyTo: null);
  }

  Future<String> getOrCreateChat(String otherUserId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    final sortedIds = [_currentUserId!, otherUserId]..sort();
    final chatId = sortedIds.join('_');

    final chatSnapshot = await _firestore.collection('chats').doc(chatId).get();
    if (!chatSnapshot.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': sortedIds,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }
}