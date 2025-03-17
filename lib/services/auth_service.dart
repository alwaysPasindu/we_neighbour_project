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
  String? _cachedToken;
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize and load token
  Future<void> init() async {
    await loadToken();
  }

  // Load token from storage
  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
      debugPrint('Token loaded: ${_cachedToken != null ? 'Yes' : 'No'}');
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  // Get JWT token (from cache or storage)
  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
      return _cachedToken;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Firebase authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Also authenticate with your backend to get JWT token
      await authenticateWithBackendOnly(email, password);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Direct backend authentication (for testing)
  Future<bool> authenticateWithBackendOnly(String email, String password) async {
    try {
      // Try multiple possible endpoints
      final endpoints = [
        '/login',
        '/api/login',
        '/api/auth/login',
        '/auth/login',
      ];
      
      for (final endpoint in endpoints) {
        try {
          debugPrint('Trying to authenticate at: $apiUrl$endpoint');
          
          final response = await http.post(
            Uri.parse('$apiUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'password': password,
            }),
          );
          
          debugPrint('Response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            String? token;
            
            // Try different token field names
            if (data['token'] != null) {
              token = data['token'];
            } else if (data['accessToken'] != null) {
              token = data['accessToken'];
            } else if (data['jwt'] != null) {
              token = data['jwt'];
            } else if (data['access_token'] != null) {
              token = data['access_token'];
            }
            
            if (token != null) {
              // Save token to shared preferences
              await _saveToken(token);
              debugPrint('✅ Backend authentication successful at $endpoint');
              return true;
            } else {
              debugPrint('❌ No token received from backend at $endpoint');
              debugPrint('Response: ${response.body}');
            }
          } else {
            debugPrint('❌ Backend authentication failed at $endpoint: ${response.statusCode}');
            debugPrint('Response: ${response.body}');
          }
        } catch (e) {
          debugPrint('❌ Error trying endpoint $endpoint: $e');
        }
      }
      
      debugPrint('❌ All authentication endpoints failed');
      return false;
    } catch (e) {
      debugPrint('❌ Error authenticating with backend: $e');
      return false;
    }
  }

  // Test API call for debugging
  Future<Map<String, dynamic>> testApiCall(String endpoint, {bool useToken = true}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (useToken) {
        final token = await getToken();
        if (token != null) {
          headers['x-auth-token'] = token;
          // Try alternative header names too
          headers['Authorization'] = 'Bearer $token';
        }
      }
      
      final url = endpoint.startsWith('http') 
          ? endpoint 
          : '$apiUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}';
      
      debugPrint('🔍 Testing API call to: $url');
      debugPrint('🔍 Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      debugPrint('🔍 Response status: ${response.statusCode}');
      
      try {
        final data = json.decode(response.body);
        debugPrint('🔍 Response data: $data');
        return {
          'status': response.statusCode,
          'data': data,
          'success': response.statusCode >= 200 && response.statusCode < 300,
        };
      } catch (e) {
        return {
          'status': response.statusCode,
          'data': response.body,
          'success': response.statusCode >= 200 && response.statusCode < 300,
          'error': 'Failed to parse JSON: $e',
        };
      }
    } catch (e) {
      debugPrint('❌ Error in test API call: $e');
      return {
        'status': 0,
        'data': null,
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Save JWT token to shared preferences
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _cachedToken = token;
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
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
    try {
      // Clear JWT token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _cachedToken = null;
      
      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

