import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_neighbour/models/chat.dart';
import 'package:we_neighbour/models/message.dart';
import 'package:logger/logger.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentApartmentName;
  final Logger logger = Logger();

  String? get currentUserId => _currentUserId;
  String? get currentApartmentName => _currentApartmentName;

  /// Sets the current user and apartment name, notifying listeners of the change
  void setUser(String userId, String apartmentName) {
    _currentUserId = userId;
    _currentApartmentName = apartmentName;
    notifyListeners();
  }

  /// Streams a list of chats for the current user (non-group chats only)
  Stream<List<Chat>> getChats() {
    if (_currentUserId == null) {
      logger.w('No current user ID set, returning empty stream');
      return const Stream.empty();
    }
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .where('isGroup', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chat.fromMap(doc.id, doc.data())).toList())
        .handleError((e) {
      logger.e('Error streaming chats: $e');
    });
  }

  /// Gets or creates a one-on-one chat with another user, returning the chat ID
  Future<String> getOrCreateChat(String otherUserId) async {
    if (_currentUserId == null) {
      logger.e('Current user ID is not set');
      throw Exception('Current user ID is not set.');
    }

    try {
      final chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .where('isGroup', isEqualTo: false)
          .get();

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
        });
        logger.d('Created new chat with ID: $chatId');
      }

      return chatId;
    } catch (e) {
      logger.e('Error in getOrCreateChat: $e');
      rethrow;
    }
  }

  /// Sends a message in the specified chat
  Future<void> sendMessage(String chatId, String content) async {
    if (_currentUserId == null) {
      logger.e('Current user ID is not set');
      throw Exception('Current user ID is not set.');
    }

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        logger.e('Chat does not exist: $chatId');
        throw Exception('Chat does not exist: $chatId');
      }

      logger.d('Sending message in chatId: $chatId, content: $content, userId: $_currentUserId');

      final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;
      await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
        'content': content,
        'senderId': _currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'isResourceMessage': false,
        'userId': _currentUserId,
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _currentUserId,
      });
    } catch (e) {
      logger.e('Error sending message: $e');
      rethrow;
    }
  }

  /// Sends a resource message, creating or updating the chat as a resource chat
  Future<void> sendResourceMessage(String chatId, String content, String otherUserId) async {
    if (_currentUserId == null) {
      logger.e('Current user ID is not set');
      throw Exception('Current user ID is not set.');
    }

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(chatId).set({
          'participants': [_currentUserId, otherUserId],
          'isGroup': false,
          'isResourceChat': true,
          'lastMessage': content,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _currentUserId,
        });
        logger.d('Created new resource chat with ID: $chatId');
      } else {
        await _firestore.collection('chats').doc(chatId).set({
          'isResourceChat': true,
          'lastMessage': content,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _currentUserId,
        }, SetOptions(merge: true));
        logger.d('Updated chat $chatId to resource chat');
      }

      final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;
      await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
        'content': content,
        'senderId': _currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'isResourceMessage': true,
        'userId': _currentUserId,
      });
    } catch (e) {
      logger.e('Error sending resource message: $e');
      rethrow;
    }
  }

  /// Deletes a message, either for everyone or just for the sender
  Future<void> deleteMessage(String chatId, String messageId, bool deleteForEveryone) async {
    if (_currentUserId == null) {
      logger.e('Current user ID is not set');
      throw Exception('Current user ID is not set.');
    }

    try {
      if (deleteForEveryone) {
        await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).delete();
        logger.d('Message $messageId deleted for everyone in chat $chatId');
      } else {
        await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
          'content': '[Deleted by Sender]',
          'senderId': _currentUserId,
          'userId': _currentUserId,
        });
        logger.d('Message $messageId marked as deleted for sender in chat $chatId');
      }
    } catch (e) {
      logger.e('Error deleting message: $e');
      rethrow;
    }
  }
}