import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final String createdByEmail;
  final DateTime createdAt;
  final String? googleEventId;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdByEmail,
    required this.createdAt,
    this.googleEventId,
  });

  factory CommunityEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      googleEventId: data['googleEventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'googleEventId': googleEventId,
    };
  }
}

