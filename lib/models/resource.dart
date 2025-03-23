class Resource {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final String apartmentCode;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.apartmentCode,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['_id'],
      title: json['resourceName'],
      description: json['description'],
      userId: json['resident']['_id'] ?? json['resident'],
      userName: json['residentName'],
      apartmentCode: json['apartmentCode'],
    );
  }
}