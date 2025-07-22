class Specialist {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String profilePictureUrl;
  final double latitude;
  final double longitude;
  final String specialization;

  Specialist({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.latitude,
    required this.longitude,
    required this.specialization,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    final coords = json['locationCoordinates'];

    return Specialist(
      id: json['_id'],
      fullName: user['fullName'],
      phoneNumber: user['phoneNumber'],
      profilePictureUrl: user['profilePictureUrl'],
      latitude: coords[1],
      longitude: coords[0],
      specialization: user['specialistProfile']?['specialization'] ?? '',
    );
  }
}
