// providers/chat_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_neighbour/models/chat.dart';
import 'package:logger/logger.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentApartmentName;
  final Logger logger = Logger();

  String? get currentUserId => _currentUserId;
  String? get currentApartmentName => _currentApartmentName;

  void setUser(String userId, String apartmentName) {
    _currentUserId = userId;
    _currentApartmentName = apartmentName;
    notifyListeners();
  }

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

  Stream<List<Chat>> getGroupChats() {
    if (_currentUserId == null) {
      logger.w('No current user ID set, returning empty stream');
      return const Stream.empty();
    }
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .where('isGroup', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chat.fromMap(doc.id, doc.data())).toList())
        .handleError((e) {
      logger.e('Error streaming group chats: $e');
    });
  }

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

  Future<String> createGroupChat(String groupName, List<String> memberIds) async {
    if (_currentUserId == null) {
      logger.e('Current user ID is not set');
      throw Exception('Current user ID is not set.');
    }

    try {
      final chatId = _firestore.collection('chats').doc().id;
      final participants = [...memberIds, _currentUserId!];

      await _firestore.collection('chats').doc(chatId).set({
        'participants': participants,
        'isGroup': true,
        'groupName': groupName,
        'lastMessage': null,
        'timestamp': FieldValue.serverTimestamp(),
        'members': participants,
        'createdBy': _currentUserId,
      });

      logger.d('Created new group chat with ID: $chatId, Name: $groupName');
      return chatId;
    } catch (e) {
      logger.e('Error creating group chat: $e');
      rethrow;
    }
  }

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

  Future<List<Map<String, dynamic>>> getApartmentUsers() async {
  if (_currentApartmentName == null || _currentUserId == null) {
    logger.w('Apartment name or user ID not set. Apartment: $_currentApartmentName, UserID: $_currentUserId');
    return [];
  }

  try {
    logger.d('Fetching users from apartments/$_currentApartmentName/users');
    final usersSnapshot = await _firestore
        .collection('apartments')
        .doc(_currentApartmentName)
        .collection('users')
        .get();

    if (usersSnapshot.docs.isEmpty) {
      logger.w('No users found in apartments/$_currentApartmentName/users');
      return [];
    }

    final users = usersSnapshot.docs
        .where((doc) => doc.id != _currentUserId)
        .map((doc) => {
              'id': doc.id,
              'name': doc.data()['name'] ?? 'Unknown User',
            })
        .toList();

    logger.d('Fetched ${users.length} users: $users');
    return users;
  } catch (e) {
    logger.e('Error fetching apartment users: $e');
    return [];
  }
}
}
