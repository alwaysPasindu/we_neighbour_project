class Service {
  final String id;
  final String title;
  final String description;
  final List<String> imagePaths;
  final String serviceProviderId;
  final String serviceProviderName;
  final ServiceLocation location;
  final String availableHours;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePaths,
    required this.serviceProviderId,
    required this.serviceProviderName,
    required this.location,
    required this.availableHours,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': imagePaths,
      'serviceProvider': serviceProviderId,
      'serviceProviderName': serviceProviderName,
      'location': location.toJson(),
      'availableHours': availableHours,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePaths: List<String>.from(json['images'] ?? []),
      serviceProviderId: json['serviceProvider'] is String
          ? json['serviceProvider'] as String
          : (json['serviceProvider'] as Map<String, dynamic>?)?['_id']?.toString() ?? '',
      serviceProviderName: json['serviceProviderName'] as String? ?? '',
      location: ServiceLocation.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      availableHours: json['availableHours'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class ServiceLocation {
  final String type;
  final List<double> coordinates;
  final String? locationAddress;

  ServiceLocation({
    this.type = 'Point',
    required this.coordinates,
    this.locationAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      if (locationAddress != null) 'address': locationAddress,
    };
  }

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      type: json['type'] as String? ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0],
      locationAddress: json['address'] as String? ?? 'Unknown Location',
    );
  }

  String get address => locationAddress ?? 'Unknown Location';
}