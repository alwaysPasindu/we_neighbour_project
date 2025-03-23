import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_neighbour/models/chat.dart';
import 'package:we_neighbour/models/message.dart';
import 'package:logger/logger.dart'; // Added logger import

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentApartmentName;
  final Logger logger = Logger(); // Added logger instance

  String? get currentUserId => _currentUserId;
  String? get currentApartmentName => _currentApartmentName;

  void setUser(String userId, String apartmentName) {
    _currentUserId = userId;
    _currentApartmentName = apartmentName;
    notifyListeners();
  }

  Stream<List<Chat>> getChats() {
    if (_currentUserId == null) return const Stream.empty();
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .where('isGroup', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chat.fromMap(doc.id, doc.data())).toList());
  }

  Future<String> getOrCreateChat(String otherUserId) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set.');
    }

    final chatSnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .where('isGroup', isEqualTo: false)
        .get()
        .catchError((e) {
          logger.d('Error querying existing chat: $e'); // Replaced print
          throw e;
        });

    String? chatId;
    for (var doc in chatSnapshot.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(_currentUserId) && participants.contains(otherUserId)) {
        chatId = doc.id;
        break;
      }
    }

    if (chatId == null) {
      chatId = _firestore.collection('chats').doc().id;
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [_currentUserId, otherUserId],
        'isGroup': false,
        'lastMessage': null,
        'timestamp': FieldValue.serverTimestamp(),
        'isResourceChat': false,
        'userId': _currentUserId,
      }).catchError((e) {
        logger.d('Error creating chat: $e'); // Replaced print
        throw e;
      });
    }

    return chatId;
  }

  Future<void> sendMessage(String chatId, String content) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set.');
    }

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      throw Exception('Chat does not exist: $chatId');
    }
    // Removed restriction for resource chats
    logger.d('Sending message in chatId: $chatId, content: $content, userId: $_currentUserId'); // Replaced print

    final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
      'content': content,
      'senderId': _currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'isResourceMessage': false,
      'userId': _currentUserId,
    }).catchError((e) {
      logger.d('Error sending message: $e'); // Replaced print
      throw e;
    });
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': _currentUserId,
    }).catchError((e) {
      logger.d('Error updating last message: $e'); // Replaced print
      throw e;
    });
  }

  Future<void> sendResourceMessage(String chatId, String content, String otherUserId) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set.');
    }

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [_currentUserId, otherUserId],
        'isGroup': false,
        'isResourceChat': true,
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _currentUserId,
      }).catchError((e) {
        logger.d('Error creating resource chat: $e'); // Replaced print
        throw e;
      });
    } else {
      await _firestore.collection('chats').doc(chatId).set({
        'isResourceChat': true,
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _currentUserId,
      }, SetOptions(merge: true)).catchError((e) {
        logger.d('Error updating chat to resource chat: $e'); // Replaced print
        throw e;
      });
    }

    final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
      'content': content,
      'senderId': _currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'isResourceMessage': true,
      'userId': _currentUserId,
    }).catchError((e) {
      logger.d('Error sending resource message: $e'); // Replaced print
      throw e;
    });
  }

  Future<void> deleteMessage(String chatId, String messageId, bool deleteForEveryone) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set.');
    }

    if (deleteForEveryone) {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete()
          .catchError((e) {
        logger.d('Error deleting message for everyone: $e'); // Replaced print
        throw e;
      });
    } else {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': '[Deleted by Sender]',
        'senderId': _currentUserId,
        'userId': _currentUserId,
      }).catchError((e) {
        logger.d('Error deleting message for sender: $e'); // Replaced print
        throw e;
      });
    }
  }
}