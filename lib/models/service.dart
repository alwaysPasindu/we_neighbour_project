class Service {
  final String id;
  final String title;
  final String description;
  final List<String> imagePaths;
  final String userId;
  final String companyName;
  final String location;
  final String availableHours;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePaths,
    required this.userId,
    required this.companyName,
    required this.location,
    required this.availableHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePaths': imagePaths,
      'userId': userId,
      'companyName': companyName,
      'location': location,
      'availableHours': availableHours,
    };
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      userId: json['userId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      availableHours: json['availableHours'] as String? ?? '',
    );
  }
}