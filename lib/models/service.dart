class Service {
  final String id;
  final String title;
  final String description;
  final List<String> imagePaths;
  final String userId;
  final String companyName;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePaths,
    required this.userId,
    required this.companyName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imagePaths': imagePaths,
        'userId': userId,
        'companyName': companyName,
      };

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        imagePaths: List<String>.from(json['imagePaths']),
        userId: json['userId'],
        companyName: json['companyName'],
      );
}