import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? website;
  final DateTime? lastSeen;
  final String? source; // Add source field to identify MongoDB users
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  final String? status;
  final String? apartmentComplexName;
  final String? apartmentCode;
  final DateTime? mongoCreatedAt;
  final DateTime? mongoUpdatedAt;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.website,
    this.lastSeen,
    this.source,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.status,
    this.apartmentComplexName,
    this.apartmentCode,
    this.mongoCreatedAt,
    this.mongoUpdatedAt,
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
      source: data['source'],
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      role: data['role'],
      status: data['status'],
      apartmentComplexName: data['apartmentComplexName'],
      apartmentCode: data['apartmentCode'],
      mongoCreatedAt: data['mongo_created_at'] != null
          ? (data['mongo_created_at'] as Timestamp).toDate()
          : null,
      mongoUpdatedAt: data['mongo_updated_at'] != null
          ? (data['mongo_updated_at'] as Timestamp).toDate()
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
      'source': source,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'status': status,
      'apartmentComplexName': apartmentComplexName,
      'apartmentCode': apartmentCode,
      'mongo_created_at': mongoCreatedAt,
      'mongo_updated_at': mongoUpdatedAt,
    };
  }
}

