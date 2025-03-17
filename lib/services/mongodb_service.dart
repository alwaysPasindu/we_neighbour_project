import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MongoDBService {
  // Your Vercel backend URL
  final String apiUrl = 'https://we-neighbour-backend.vercel.app';
  
  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch users from MongoDB API
  Future<List<Map<String, dynamic>>> fetchAndSyncUsers({String? authToken}) async {
    debugPrint('🔄 Starting MongoDB user fetch...');
    try {
      if (authToken == null) {
        debugPrint('❌ No authentication token provided');
        return _fetchUsersDirectlyFromFirestore();
      }
      
      // Try multiple endpoints
      final endpoints = [
        '/chat-residents',
        '/api/chat-residents',
        '/api/residents',
        '/residents',
      ];
      
      for (final endpoint in endpoints) {
        try {
          debugPrint('📡 Trying endpoint: $apiUrl$endpoint');
          
          final response = await http.get(
            Uri.parse('$apiUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': authToken,
            },
          );
          
          debugPrint('📊 Response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            // Parse the response
            final data = json.decode(response.body);
            debugPrint('✅ Fetched data from $endpoint');
            
            // Handle different response formats
            List<dynamic> usersList;
            
            if (data is List) {
              usersList = data;
            } else if (data is Map<String, dynamic>) {
              if (data.containsKey('residents')) {
                usersList = data['residents'] as List;
              } else if (data.containsKey('users')) {
                usersList = data['users'] as List;
              } else if (data.containsKey('data')) {
                usersList = data['data'] as List;
              } else {
                debugPrint('⚠️ Unexpected response format from $endpoint. Trying next endpoint.');
                continue;
              }
            } else {
              debugPrint('⚠️ Unexpected response type from $endpoint. Trying next endpoint.');
              continue;
            }
            
            debugPrint('✅ Extracted ${usersList.length} users from response');
            
            // Convert to List<Map<String, dynamic>>
            final List<Map<String, dynamic>> users = 
                usersList.map((user) => user as Map<String, dynamic>).toList();
            
            // Debug the first user to see its structure
            if (users.isNotEmpty) {
              debugPrint('📄 Sample user data: ${json.encode(users.first)}');
            }
            
            // Sync each user to Firestore
            for (var user in users) {
              await _syncUserToFirestore(user);
            }
            
            return users;
          } else if (response.statusCode == 401) {
            debugPrint('❌ Authentication failed for $endpoint: ${response.body}');
          } else {
            debugPrint('❌ Failed to load users from $endpoint: ${response.statusCode}');
            debugPrint('Response body: ${response.body}');
          }
        } catch (e) {
          debugPrint('❌ Error with endpoint $endpoint: $e');
        }
      }
      
      debugPrint('❌ All endpoints failed. Falling back to Firestore.');
      return _fetchUsersDirectlyFromFirestore();
    } catch (e) {
      debugPrint('❌ Error fetching users: $e');
      return _fetchUsersDirectlyFromFirestore();
    }
  }

  // Fetch users directly from Firestore as a fallback
  Future<List<Map<String, dynamic>>> _fetchUsersDirectlyFromFirestore() async {
    debugPrint('🔍 Attempting to fetch users directly from Firestore');
    try {
      final List<Map<String, dynamic>> allUsers = [];
      
      // Try different collection paths
      final collectionPaths = [
        'apartments/ApartmentC/users',
        'users',
        'residents',
      ];
      
      for (final path in collectionPaths) {
        try {
          debugPrint('🔍 Trying collection path: $path');
          final pathParts = path.split('/');
          
          QuerySnapshot snapshot;
          if (pathParts.length == 1) {
            // Simple collection
            snapshot = await _firestore.collection(pathParts[0]).get();
          } else if (pathParts.length == 3) {
            // Collection group pattern
            snapshot = await _firestore
                .collection(pathParts[0])
                .doc(pathParts[1])
                .collection(pathParts[2])
                .get();
          } else {
            continue;
          }
          
          debugPrint('✅ Found ${snapshot.docs.length} users in Firestore path: $path');
          
          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final userData = doc.data() as Map<String, dynamic>;
              userData['_id'] = doc.id; // Add document ID as _id
              allUsers.add(userData);
              
              // Sync to the main users collection if not already there
              await _syncUserToFirestore({
                '_id': {'\$oid': doc.id},
                ...userData,
                'source': 'mongodb', // Mark as MongoDB source
                'collection_path': path, // Add the collection path for reference
              });
            }
          }
        } catch (e) {
          debugPrint('❌ Error with collection path $path: $e');
        }
      }
      
      // Also try to fetch all apartments
      try {
        final apartmentsSnapshot = await _firestore.collection('apartments').get();
        debugPrint('Found ${apartmentsSnapshot.docs.length} apartments');
        
        for (final apartmentDoc in apartmentsSnapshot.docs) {
          try {
            final usersSnapshot = await _firestore
                .collection('apartments')
                .doc(apartmentDoc.id)
                .collection('users')
                .get();
            
            debugPrint('Found ${usersSnapshot.docs.length} users in apartment ${apartmentDoc.id}');
            
            for (var doc in usersSnapshot.docs) {
              final userData = doc.data() as Map<String, dynamic>;
              userData['_id'] = doc.id;
              userData['apartmentId'] = apartmentDoc.id;
              allUsers.add(userData);
              
              // Sync to the main users collection
              await _syncUserToFirestore({
                '_id': {'\$oid': doc.id},
                ...userData,
                'source': 'mongodb',
                'apartmentId': apartmentDoc.id,
                'collection_path': 'apartments/${apartmentDoc.id}/users',
              });
            }
          } catch (e) {
            debugPrint('Error fetching users for apartment ${apartmentDoc.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('Error fetching apartments: $e');
      }
      
      debugPrint('Total users found across all collections: ${allUsers.length}');
      return allUsers;
    } catch (e) {
      debugPrint('❌ Error fetching users from Firestore: $e');
      return [];
    }
  }

  // Sync a single user from MongoDB to Firestore
  Future<void> _syncUserToFirestore(Map<String, dynamic> mongoUser) async {
    try {
      // Extract MongoDB _id as userId - handle both string and object formats
      String userId;
      if (mongoUser['_id'] is Map && mongoUser['_id'].containsKey('\$oid')) {
        userId = mongoUser['_id']['\$oid'].toString();
      } else if (mongoUser['_id'] is String) {
        userId = mongoUser['_id'];
      } else {
        userId = mongoUser['_id'].toString();
      }
      
      debugPrint('🔄 Syncing user: $userId');
      
      // Check if user already exists in Firestore
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      // Map MongoDB user to Firestore user format based on your specific structure
      final firestoreUser = {
        'id': userId,
        'username': mongoUser['name'] ?? mongoUser['username'] ?? 'User $userId',
        'email': mongoUser['email'] ?? '',
        'phone': mongoUser['phone'] ?? '',
        'address': mongoUser['address'] ?? '',
        'avatar_url': mongoUser['avatar_url'] ?? mongoUser['avatarUrl'] ?? '',
        'role': mongoUser['role'] ?? '',
        'status': mongoUser['status'] ?? '',
        'apartmentComplexName': mongoUser['apartmentComplexName'] ?? mongoUser['apartment_complex_name'] ?? '',
        'apartmentCode': mongoUser['apartmentCode'] ?? mongoUser['apartment_code'] ?? '',
        'apartmentId': mongoUser['apartmentId'] ?? '',
        'collection_path': mongoUser['collection_path'] ?? '',
        'source': 'mongodb', // Mark as MongoDB source
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      if (!docSnapshot.exists) {
        debugPrint('➕ Adding new user to Firestore: $userId');
        // Add user to Firestore
        await _firestore.collection('users').doc(userId).set(firestoreUser);
      } else {
        debugPrint('🔄 Updating existing user in Firestore: $userId');
        // Update existing user
        await _firestore.collection('users').doc(userId).update(firestoreUser);
      }
    } catch (e) {
      debugPrint('❌ Error syncing user to Firestore: $e');
      // Don't throw, just log the error
      debugPrint('Error details: $e');
    }
  }
  
  // Get a specific user from MongoDB by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    debugPrint('🔍 Getting user by ID: $userId');
    
    // Try Firestore first (faster)
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      debugPrint('✅ Found user in Firestore');
      return docSnapshot.data();
    }
    
    // No specific endpoint for getting a single resident by ID in your routes
    // We would need to fetch all and filter, but that's inefficient
    // For now, we'll just return null if not found in Firestore
    return null;
  }
}

