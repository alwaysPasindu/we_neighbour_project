import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(String title, DateTime date) async {
    await _firestore.collection('events').add({
      'title': title,
      'date': date,
    });
  }

  Stream<QuerySnapshot> getEvents() {
    return _firestore.collection('events').orderBy('date').snapshots();
  }
}
