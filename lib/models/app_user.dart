class AppUser {
  final String id;
  final String email;

  const AppUser({required this.id, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(id: json['id'], email: json['email']);
  }
}