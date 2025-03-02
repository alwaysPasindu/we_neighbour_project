class Resource {
  final String id;
  final String title;
  final String description;
  final String requestId;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final bool isActive;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.requestId,
    required this.userId,
    required this.userName,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Add a method to create Resource from JSON
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Add a method to convert Resource to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requestId': requestId,
      'userId': userId,
      'userName': userName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}