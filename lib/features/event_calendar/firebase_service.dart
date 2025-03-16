import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updated method with all required parameters
  Future<void> addEvent(
    String title, 
    DateTime date, 
    DateTime? endTime, 
    String? notes, 
    String type
  ) async {
    try {
      await _firestore.collection('events').add({
        'title': title,
        'date': date,
        'endTime': endTime,
        'notes': notes,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Event added successfully: $title on $date');
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  // New method for booking amenities
  Future<void> bookAmenity(
    String amenityName,
    DateTime startDateTime,
    DateTime endDateTime,
    String? notes
  ) async {
    try {
      await _firestore.collection('events').add({
        'title': amenityName,
        'date': startDateTime,
        'endTime': endDateTime,
        'notes': notes,
        'type': 'amenity',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Amenity booked successfully: $amenityName');
    } catch (e) {
      print('Error booking amenity: $e');
      rethrow;
    }
  }

  // New method for booking health activities
  Future<void> bookHealthActivity(
    String activityName,
    DateTime startDateTime,
    DateTime endDateTime,
    String? notes
  ) async {
    try {
      await _firestore.collection('events').add({
        'title': activityName,
        'date': startDateTime,
        'endTime': endDateTime,
        'notes': notes,
        'type': 'health',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Health activity booked successfully: $activityName');
    } catch (e) {
      print('Error booking health activity: $e');
      rethrow;
    }
  }

  // Existing methods below
  Stream<QuerySnapshot> getEvents() {
    try {
      print('Getting events from Firestore');
      return _firestore.collection('events').orderBy('date').snapshots();
    } catch (e) {
      print('Error getting events: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEventsOnce() async {
    try {
      print('Getting events once from Firestore');
      final snapshot =
          await _firestore.collection('events').orderBy('date').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting events once: $e');
      return [];
    }
  }

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