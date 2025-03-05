import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updated method signature to accept all parameters
  Future<void> addEvent(String title, DateTime date,
      [DateTime? endTime, String? notes, String type = 'event']) async {
    try {
      final Map<String, dynamic> eventData = {
        'title': title,
        'date': date,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Only add these fields if they are not null
      if (endTime != null) {
        eventData['endTime'] = endTime;
      }

      if (notes != null && notes.isNotEmpty) {
        eventData['notes'] = notes;
      }

      await _firestore.collection('events').add(eventData);
      print('Event added successfully: $title on $date');
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  Future<void> bookAmenity(
    String amenityName,
    DateTime startTime,
    DateTime endTime,
    String notes,
  ) async {
    try {
      await _firestore.collection('events').add({
        'title': 'Booked: $amenityName',
        'date': startTime,
        'endTime': endTime,
        'type': 'amenity',
        'amenityName': amenityName,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print(
          'Amenity booked successfully: $amenityName from $startTime to $endTime');
    } catch (e) {
      print('Error booking amenity: $e');
      rethrow;
    }
  }

  // Add a new method for booking health and wellness activities
  Future<void> bookHealthActivity(
    String activityName,
    DateTime startTime,
    DateTime endTime,
    String notes,
  ) async {
    try {
      await _firestore.collection('events').add({
        'title': 'Health: $activityName',
        'date': startTime,
        'endTime': endTime,
        'type': 'health',
        'activityName': activityName,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print(
          'Health activity booked successfully: $activityName from $startTime to $endTime');
    } catch (e) {
      print('Error booking health activity: $e');
      rethrow;
    }
  }

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
