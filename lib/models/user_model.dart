class User {
  final String id;
  final String username;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? profilePictureUrl;
  final String? farmName;
  final String? specialization;
  final String? certificationImage;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.profilePictureUrl,
    this.farmName,
    this.specialization,
    this.certificationImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      farmName: json['farmName']?.toString(),
      specialization: json['specialization']?.toString(),
      certificationImage: json['certificationImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'farmName': farmName,
      'specialization': specialization,
      'certificationImage': certificationImage,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': user.toJson(),
    };
  }
}