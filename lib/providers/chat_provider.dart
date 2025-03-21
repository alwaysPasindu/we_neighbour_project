import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_neighbour/models/chat.dart' as chat_model;


class ChatProvider with ChangeNotifier {
  String? _currentUserId;
  String? _currentApartmentName;
  List<chat_model.Chat> _oneToOneChats = [];
  List<chat_model.Chat> _groupChats = [];

  String? get currentUserId => _currentUserId;
  String? get currentApartmentName => _currentApartmentName;
  List<chat_model.Chat> get oneToOneChats => _oneToOneChats;
  List<chat_model.Chat> get groupChats => _groupChats;

  ChatProvider() {
    _currentUserId = null;
    _currentApartmentName = null;
  }

  Future<void> setUser(String userId, String apartmentName) async {
    print('Setting user in ChatProvider: userId=$userId, apartmentName=$apartmentName');
    _currentUserId = userId; // Use the backend userId
    _currentApartmentName = apartmentName;
    await fetchChats();
    notifyListeners();
  }


  Future<void> fetchChats() async {
    if (_currentUserId == null || _currentApartmentName == null) {
      print('Cannot fetch chats: userId or apartmentName is null');
      return;
    }

    try {
      print('Fetching one-to-one chats for user: $_currentUserId');
      final oneToOneQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .where('isGroup', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();
      _oneToOneChats = oneToOneQuery.docs.map((doc) => chat_model.Chat.fromDocument(doc)).toList();
      print('Fetched ${_oneToOneChats.length} one-to-one chats.');

      print('Fetching groups for user: $_currentUserId');
      final groupQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('members', arrayContains: _currentUserId)
          .where('isGroup', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();
      _groupChats = groupQuery.docs.map((doc) => chat_model.Chat.fromDocument(doc)).toList();
      print('Fetched ${_groupChats.length} groups.');

      notifyListeners();
    } catch (e) {
      print('Error fetching chats: $e');
      rethrow; // Throw the error to be caught by the caller
    }
  }

  List<chat_model.Chat> getChats() {
    return [..._oneToOneChats];
  }

  List<chat_model.Chat> getGroups() {
    return [..._groupChats];
  }

  Future<String> getUserName(String userId, String apartmentName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('home')
          .doc('apartment')
          .collection('apartments')
          .doc(apartmentName)
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data()?['name'] as String? ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      print('Error fetching user name: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUsersForGroupCreation(String apartmentName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('home')
          .doc('apartment')
          .collection('apartments')
          .doc(apartmentName)
          .collection('users')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching users for group creation: $e');
      rethrow;
    }
  }

  Future<String> getOrCreateChat(String otherUserId, {String? resourceId}) async {
    if (_currentUserId == null || _currentApartmentName == null) {
      throw Exception('User ID or apartment name is not set');
    }

    final participants = [_currentUserId!, otherUserId]..sort();
    final chatId = participants.join('_');

    print('Creating or fetching chat with participants: $participants, chatId: $chatId');

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': participants,
        'isGroup': false,
        'lastMessage': null,
        'timestamp': FieldValue.serverTimestamp(),
        'resourceId': resourceId,
      });
      print('Created new chat with ID: $chatId, resourceId: $resourceId');
      await fetchChats();
    } else {
      print('Chat already exists with ID: $chatId');
    }

    return chatId;
  }

  Future<String> createGroup(String groupName, List<String> selectedUserIds) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set');
    }

    final members = [...selectedUserIds, _currentUserId!];
    final chatRef = FirebaseFirestore.instance.collection('chats').doc();
    await chatRef.set({
      'members': members,
      'isGroup': true,
      'groupName': groupName,
      'lastMessage': null,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Created group with ID: ${chatRef.id}');
    await fetchChats();
    return chatRef.id;
  }

  Future<void> sendMessage(String chatId, String content) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set');
    }

    final messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    await messageRef.set({
      'senderId': _currentUserId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Sent message to chat ID: $chatId');
    await fetchChats();
  }


  Future<void> deleteMessage(String chatId, String messageId) async {
    if (_currentUserId == null) {
      throw Exception('Current user ID is not set');
    }

    final messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    final messageDoc = await messageRef.get();
    if (messageDoc.exists && messageDoc.data()?['senderId'] == _currentUserId) {
      await messageRef.delete();
      print('Deleted message $messageId from chat $chatId');
    } else {
      throw Exception('Permission denied or message not found');
    }
  }
}