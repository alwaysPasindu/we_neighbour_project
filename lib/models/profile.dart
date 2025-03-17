import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? website;
  final DateTime? lastSeen;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.website,
    this.lastSeen,
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      id: doc.id,
      username: data['username'] ?? 'Unknown',
      avatarUrl: data['avatar_url'],
      website: data['website'],
      lastSeen: data['last_seen'] != null 
          ? (data['last_seen'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'website': website,
      'last_seen': lastSeen,
    };
  }
}

