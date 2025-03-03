import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_event.dart';

class CommunityEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get all community events
  Stream<List<CommunityEvent>> getCommunityEvents() {
    return _firestore
        .collection('community_events')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommunityEvent.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get events for a specific month
  Stream<List<CommunityEvent>> getEventsForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    return _firestore
        .collection('community_events')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommunityEvent.fromFirestore(doc))
              .toList();
        });
  }
  
  // Add a new community event
  Future<String> addCommunityEvent(CommunityEvent event) async {
    try {
      final docRef = await _firestore.collection('community_events').add(event.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add community event: $e');
    }
  }
  
  // Update a community event
  Future<void> updateCommunityEvent(String id, CommunityEvent event) async {
    try {
      await _firestore.collection('community_events').doc(id).update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update community event: $e');
    }
  }
  
  // Delete a community event
  Future<void> deleteCommunityEvent(String id) async {
    try {
      await _firestore.collection('community_events').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete community event: $e');
    }
  }
  
  // Get events created by the current user
  Stream<List<CommunityEvent>> getUserEvents() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('community_events')
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommunityEvent.fromFirestore(doc))
              .toList();
        });
  }
}

