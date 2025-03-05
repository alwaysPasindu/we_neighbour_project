class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String provider;
  final DateTime createdAt;
  final DateTime? lastSignIn;
  final String? accountType; // resident, manager, or service_provider

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.provider,
    required this.createdAt,
    this.lastSignIn,
    this.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      provider: json['provider'],
      createdAt: DateTime.parse(json['created_at']),
      lastSignIn: json['last_sign_in'] != null 
          ? DateTime.parse(json['last_sign_in']) 
          : null,
      accountType: json['account_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'provider': provider,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in': lastSignIn?.toIso8601String(),
      'account_type': accountType,
    };
  }
}

