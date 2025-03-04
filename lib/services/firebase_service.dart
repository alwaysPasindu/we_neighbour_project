import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(String title, DateTime date) async {
    await _firestore.collection('events').add({
      'title': title,
      'date': date,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getEvents() {
    return _firestore.collection('events').orderBy('date').snapshots();
  }

  Future<void> updateEvent(String docId, String title, DateTime date) async {
    await _firestore.collection('events').doc(docId).update({
      'title': title,
      'date': date,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(String docId) async {
    await _firestore.collection('events').doc(docId).delete();
  }
}
