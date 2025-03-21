import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_neighbour/utils/auth_utils.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current user ID
  Future<String?> _getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return await AuthUtils.getUserId(); // Fallback to SharedPreferences if needed
  }

  // Add an event
  Future<void> addEvent(
    String title,
    DateTime date,
    DateTime? endTime,
    String? notes,
    String type,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('events').add({
        'title': title,
        'date': date,
        'endTime': endTime,
        'notes': notes,
        'type': type,
        'creatorId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Event added successfully: $title on $date');
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  // Book an amenity
  Future<void> bookAmenity(
    String amenityName,
    DateTime startDateTime,
    DateTime endDateTime,
    String? notes,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('events').add({
        'title': amenityName,
        'date': startDateTime,
        'endTime': endDateTime,
        'notes': notes,
        'type': 'amenity',
        'creatorId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Amenity booked successfully: $amenityName');
    } catch (e) {
      print('Error booking amenity: $e');
      rethrow;
    }
  }

  // Book a health activity
  Future<void> bookHealthActivity(
    String activityName,
    DateTime startDateTime,
    DateTime endDateTime,
    String? notes,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('events').add({
        'title': activityName,
        'date': startDateTime,
        'endTime': endDateTime,
        'notes': notes,
        'type': 'health',
        'creatorId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Health activity booked successfully: $activityName');
    } catch (e) {
      print('Error booking health activity: $e');
      rethrow;
    }
  }

  // Get events stream
  Stream<QuerySnapshot> getEvents() {
    try {
      print('Getting events from Firestore');
      return _firestore.collection('events').orderBy('date').snapshots();
    } catch (e) {
      print('Error getting events: $e');
      rethrow;
    }
  }

  // Get events once
  Future<List<Map<String, dynamic>>> getEventsOnce() async {
    try {
      print('Getting events once from Firestore');
      final snapshot = await _firestore.collection('events').orderBy('date').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting events once: $e');
      return [];
    }
  }

  // Update an event
  Future<void> updateEvent(String docId, String title, DateTime date) async {
    try {
      await _firestore.collection('events').doc(docId).update({
        'title': title,
        'date': date,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Event updated successfully: $docId');
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String docId) async {
    try {
      await _firestore.collection('events').doc(docId).delete();
      print('Event deleted successfully: $docId');
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
}