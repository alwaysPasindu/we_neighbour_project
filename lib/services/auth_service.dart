import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String apiUrl = 'https://we-neighbour-backend.vercel.app';
  
  // JWT token storage key
  static const String _tokenKey = 'jwt_token';
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Firebase authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Also authenticate with your backend to get JWT token
      await _authenticateWithBackend(email, password);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Authenticate with backend to get JWT token
  Future<void> _authenticateWithBackend(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        
        if (token != null) {
          // Save token to shared preferences
          await _saveToken(token);
          debugPrint('✅ Backend authentication successful');
        } else {
          debugPrint('❌ No token received from backend');
        }
      } else {
        debugPrint('❌ Backend authentication failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error authenticating with backend: $e');
      // Continue even if backend auth fails - we'll still have Firebase auth
    }
  }

  // Save JWT token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get JWT token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Clear JWT token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    
    // Sign out from Firebase
    await _auth.signOut();
  }
}

