enum UserStatus { online, offline, away }

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final UserStatus status;
  final DateTime lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.status = UserStatus.offline,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  factory ChatUser.fromMap(Map<String, dynamic> map, String id) {
    return ChatUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => UserStatus.offline,
      ),
      lastSeen: map['lastSeen'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'status': status.toString(),
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }
}
