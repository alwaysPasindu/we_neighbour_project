import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/chat_user.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _firebaseUser;
  ChatUser? _chatUser;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  ChatUser? get chatUser => _chatUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    _isLoading = true;
    notifyListeners();

    _firebaseUser = await _firebaseService.getCurrentUser();
    if (_firebaseUser != null) {
      // Set user status to online
      await _firebaseService.updateUserStatus(_firebaseUser!.uid, UserStatus.online);
      
      // Listen to user data changes
      _firebaseService.userStream(_firebaseUser!.uid).listen((user) {
        _chatUser = user;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_firebaseUser != null) {
      // Set user status to offline before signing out
      await _firebaseService.updateUserStatus(_firebaseUser!.uid, UserStatus.offline);
      await _firebaseService.signOut();
      _firebaseUser = null;
      _chatUser = null;
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(UserStatus status) async {
    if (_firebaseUser != null) {
      await _firebaseService.updateUserStatus(_firebaseUser!.uid, status);
    }
  }
}

