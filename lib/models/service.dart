class Service {
  final String id;
  final String title;
  final String description;
  final List<String> imagePaths;
  final String userId;
  final String companyName;
  final String location; // Add this
  final String availableHours; // Add this

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePaths,
    required this.userId,
    required this.companyName,
    required this.location, // Add this
    required this.availableHours, // Add this
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePaths': imagePaths,
      'userId': userId,
      'companyName': companyName,
      'location': location, // Add this
      'availableHours': availableHours, // Add this
    };
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imagePaths: List<String>.from(json['imagePaths']),
      userId: json['userId'],
      companyName: json['companyName'],
      location: json['location'] ?? '', // Add this with default value
      availableHours: json['availableHours'] ?? '', // Add this with default value
    );
  }
}