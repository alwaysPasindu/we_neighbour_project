import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MongoDBService {
  // Replace with your MongoDB API endpoint
  final String apiUrl = 'YOUR_MONGODB_API_ENDPOINT';
  
  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch users from MongoDB and sync to Firestore with debug logging
  Future<List<Map<String, dynamic>>> fetchAndSyncUsers() async {
    debugPrint('🔄 Starting MongoDB user fetch...');
    try {
      // Make HTTP request to your MongoDB API
      debugPrint('📡 Requesting data from: $apiUrl/users');
      
      // For debugging, let's add a direct connection to your Firestore collection
      // This is a temporary solution to see if we can access the data directly
      if (apiUrl == 'YOUR_MONGODB_API_ENDPOINT') {
        debugPrint('⚠️ Using direct Firestore access instead of MongoDB API');
        return _fetchUsersDirectlyFromFirestore();
      }
      
      final response = await http.get(
        Uri.parse('$apiUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // If needed
        },
      );

      debugPrint('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ Fetched ${data.length} users from MongoDB');
        
        final List<Map<String, dynamic>> users = 
            data.map((user) => user as Map<String, dynamic>).toList();
        
        // Sync each user to Firestore
        for (var user in users) {
          await _syncUserToFirestore(user);
        }
        
        return users;
      } else {
        debugPrint('❌ Failed to load users: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Temporary method to fetch users directly from Firestore
  // This is for debugging when MongoDB API is not yet set up
  Future<List<Map<String, dynamic>>> _fetchUsersDirectlyFromFirestore() async {
    debugPrint('🔍 Attempting to fetch users directly from Firestore collection "apartments/ApartmentC/users"');
    try {
      // Try to fetch from the collection path shown in your screenshot
      final snapshot = await _firestore.collection('apartments').doc('ApartmentC').collection('users').get();
      
      debugPrint('✅ Found ${snapshot.docs.length} users in Firestore');
      
      final List<Map<String, dynamic>> users = [];
      
      for (var doc in snapshot.docs) {
        final userData = doc.data();
        userData['_id'] = doc.id; // Add document ID as _id
        users.add(userData);
        
        // Sync to the main users collection
        await _syncUserToFirestore({
          '_id': {'\$oid': doc.id},
          ...userData,
          'source': 'mongodb' // Mark as MongoDB source
        });
      }
      
      return users;
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
      
      // Debug the MongoDB user data
      debugPrint('📄 MongoDB user data: ${json.encode(mongoUser)}');
      
      // Check if user already exists in Firestore
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      // Map MongoDB user to Firestore user format based on your specific structure
      final firestoreUser = {
        'id': userId,
        'username': mongoUser['name'] ?? 'User $userId',
        'email': mongoUser['email'] ?? '',
        'phone': mongoUser['phone'] ?? '',
        'address': mongoUser['address'] ?? '',
        'avatar_url': mongoUser['avatar_url'] ?? '',
        'role': mongoUser['role'] ?? '',
        'status': mongoUser['status'] ?? '',
        'apartmentComplexName': mongoUser['apartmentComplexName'] ?? '',
        'apartmentCode': mongoUser['apartmentCode'] ?? '',
        'source': 'mongodb', // Mark as MongoDB source
        'updated_at': FieldValue.serverTimestamp(),
        'mongo_created_at': _extractMongoDate(mongoUser, 'createdAt'),
        'mongo_updated_at': _extractMongoDate(mongoUser, 'updatedAt'),
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
      throw Exception('Error syncing user to Firestore: $e');
    }
  }
  
  // Helper method to extract MongoDB date
  DateTime? _extractMongoDate(Map<String, dynamic> mongoUser, String field) {
    try {
      if (mongoUser[field] != null) {
        if (mongoUser[field] is Map && 
            mongoUser[field]['\$date'] is Map && 
            mongoUser[field]['\$date']['\$numberLong'] != null) {
          // Handle the nested structure: {"$date":{"$numberLong":"1741206040578"}}
          final timestamp = int.parse(mongoUser[field]['\$date']['\$numberLong']);
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (mongoUser[field] is String) {
          // Handle string date format
          return DateTime.parse(mongoUser[field]);
        }
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error parsing date field $field: $e');
      return null;
    }
  }
  
  // Get a specific user from MongoDB by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    debugPrint('🔍 Getting user by ID: $userId');
    try {
      // For debugging, check Firestore first
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        debugPrint('✅ Found user in Firestore');
        return docSnapshot.data();
      }
      
      // If not in Firestore, try the API
      final response = await http.get(
        Uri.parse('$apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // If needed
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Found user via API');
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ User not found via API');
        return null;
      } else {
        debugPrint('❌ Failed to get user: ${response.statusCode}');
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      throw Exception('Error getting user: $e');
    }
  }
}

