// lib/data/models/user.dart

class User {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final DateTime createdAt;
  final UserStatus status;
  final List<UserRole> roles;
  final UserSettings settings;
  final EmergencyInfo emergencyInfo;

  User({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.createdAt,
    this.status = UserStatus.active,
    this.roles = const [UserRole.user],
    required this.settings,
    required this.emergencyInfo,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'roles': roles.map((role) => role.name).toList(),
      'settings': settings.toJson(),
      'emergencyInfo': emergencyInfo.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      status: UserStatus.values.firstWhere((e) => e.name == json['status']),
      roles: (json['roles'] as List)
          .map((role) => UserRole.values.firstWhere((e) => e.name == role))
          .toList(),
      settings: UserSettings.fromJson(json['settings']),
      emergencyInfo: EmergencyInfo.fromJson(json['emergencyInfo']),
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool communityAlertsEnabled;
  final int communityRadius; // en mètres
  final String language;
  final bool darkMode;
  final bool biometricAuth;
  final int emergencyTimeout; // minutes avant alerte communautaire
  final bool locationSharing;
  final bool autoConnectBracelet;
  final bool discreetMode;

  UserSettings({
    this.notificationsEnabled = true,
    this.communityAlertsEnabled = true,
    this.communityRadius = 1000,
    this.language = 'fr',
    this.darkMode = false,
    this.biometricAuth = false,
    this.emergencyTimeout = 3,
    this.locationSharing = true,
    this.autoConnectBracelet = true,
    this.discreetMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'communityAlertsEnabled': communityAlertsEnabled,
      'communityRadius': communityRadius,
      'language': language,
      'darkMode': darkMode,
      'biometricAuth': biometricAuth,
      'emergencyTimeout': emergencyTimeout,
      'locationSharing': locationSharing,
      'autoConnectBracelet': autoConnectBracelet,
      'discreetMode': discreetMode,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'],
      communityAlertsEnabled: json['communityAlertsEnabled'],
      communityRadius: json['communityRadius'],
      language: json['language'],
      darkMode: json['darkMode'],
      biometricAuth: json['biometricAuth'],
      emergencyTimeout: json['emergencyTimeout'],
      locationSharing: json['locationSharing'],
      autoConnectBracelet: json['autoConnectBracelet'],
      discreetMode: json['discreetMode'] ?? false,
    );
  }
}

class EmergencyInfo {
  final String? bloodType;
  final List<String>? allergies;
  final String? medicalConditions;
  final String? emergencyContactNote;
  final String? address;
  final String? workplace;
  final String? school;

  EmergencyInfo({
    this.bloodType,
    this.allergies,
    this.medicalConditions,
    this.emergencyContactNote,
    this.address,
    this.workplace,
    this.school,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'emergencyContactNote': emergencyContactNote,
      'address': address,
      'workplace': workplace,
      'school': school,
    };
  }

  factory EmergencyInfo.fromJson(Map<String, dynamic> json) {
    return EmergencyInfo(
      bloodType: json['bloodType'],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      medicalConditions: json['medicalConditions'],
      emergencyContactNote: json['emergencyContactNote'],
      address: json['address'],
      workplace: json['workplace'],
      school: json['school'],
    );
  }
}

enum UserStatus { active, suspended, pending, blocked }

enum UserRole { user, admin, moderator, support }
