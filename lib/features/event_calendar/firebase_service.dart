import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_neighbour/utils/auth_utils.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  // Helper to get the current user ID
  Future<String?> _getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return await AuthUtils.getUserId();
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
      logger.d('Event added successfully: $title on $date');
    } catch (e) {
      logger.d('Error adding event: $e');
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
      logger.d('Amenity booked successfully: $amenityName');
    } catch (e) {
      logger.d('Error booking amenity: $e');
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
      logger.d('Health activity booked successfully: $activityName');
    } catch (e) {
      logger.d('Error booking health activity: $e');
      rethrow;
    }
  }

  // Get all events stream
  Stream<QuerySnapshot> getEvents() {
    try {
      logger.d('Getting events from Firestore');
      return _firestore.collection('events').orderBy('date').snapshots();
    } catch (e) {
      logger.d('Error getting events: $e');
      rethrow;
    }
  }

  // Get upcoming events stream (events from today onward)
  Stream<QuerySnapshot> getUpcomingEvents() {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      logger.d('Getting upcoming events from Firestore');
      return _firestore
          .collection('events')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .orderBy('date')
          .snapshots();
    } catch (e) {
      logger.d('Error getting upcoming events: $e');
      rethrow;
    }
  }

  // Get events once
  Future<List<Map<String, dynamic>>> getEventsOnce() async {
    try {
      logger.d('Getting events once from Firestore');
      final snapshot =
          await _firestore.collection('events').orderBy('date').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      logger.d('Error getting events once: $e');
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
      logger.d('Event updated successfully: $docId');
    } catch (e) {
      logger.d('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String docId) async {
    try {
      await _firestore.collection('events').doc(docId).delete();
      logger.d('Event deleted successfully: $docId');
    } catch (e) {
      logger.d('Error deleting event: $e');
      rethrow;
    }
  }
}
