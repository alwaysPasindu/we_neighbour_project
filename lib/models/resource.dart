class Resource {
  final String id;
  final String title;
  final String description;
  final String requestId;
  final String userId;
  final String userName;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.requestId,
    required this.userId,
    required this.userName,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['_id'],
      title: json['resourceName'],
      description: json['description'],
      requestId: 'REQ${DateTime.now().millisecondsSinceEpoch}', // Adjust if backend provides a requestId
      userId: json['resident']['_id'] ?? json['resident'], // Handle both object and string formats
      userName: json['residentName'],
    );
  }
}