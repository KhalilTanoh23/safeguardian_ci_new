// lib/data/models/alert.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modèle représentant une alerte d'urgence
class EmergencyAlert {
  final String id;
  final String userId;
  final LatLng location;
  final DateTime timestamp;
  final AlertStatus status;
  final List<String> notifiedContacts;
  final bool communityAlertSent;
  final String? message;
  final List<AlertResponse> responses;

  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.location,
    required this.timestamp,
    this.status = AlertStatus.pending,
    this.notifiedContacts = const [],
    this.communityAlertSent = false,
    this.message,
    this.responses = const [],
  });

  /// Nombre de contacts ayant confirmé qu'ils peuvent aider
  int get confirmedContacts =>
      responses.where((response) => response.canHelp).length;

  /// Vérifie si l'alerte est encore active
  bool get isActive =>
      status == AlertStatus.pending || status == AlertStatus.confirmed;

  /// Sérialisation en JSON pour stockage ou envoi à une API
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'latitude': location.latitude,
    'longitude': location.longitude,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'notifiedContacts': notifiedContacts,
    'communityAlertSent': communityAlertSent,
    'message': message,
    'responses': responses.map((r) => r.toJson()).toList(),
  };

  /// Création d'un objet à partir d'un JSON
  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] as String,
      userId: json['userId'] as String,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.pending,
      ),
      notifiedContacts: List<String>.from(json['notifiedContacts'] ?? []),
      communityAlertSent: json['communityAlertSent'] as bool? ?? false,
      message: json['message'] as String?,
      responses:
          (json['responses'] as List<dynamic>?)
              ?.map((r) => AlertResponse.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Réponse d'un contact à une alerte
class AlertResponse {
  final String contactId;
  final String contactName;
  final DateTime responseTime;
  final bool canHelp;
  final String? message;
  final double? distance;

  AlertResponse({
    required this.contactId,
    required this.contactName,
    required this.responseTime,
    required this.canHelp,
    this.message,
    this.distance,
  });

  /// Sérialisation en JSON
  Map<String, dynamic> toJson() => {
    'contactId': contactId,
    'contactName': contactName,
    'responseTime': responseTime.toIso8601String(),
    'canHelp': canHelp,
    'message': message,
    'distance': distance,
  };

  /// Création à partir d'un JSON
  factory AlertResponse.fromJson(Map<String, dynamic> json) {
    return AlertResponse(
      contactId: json['contactId'] as String,
      contactName: json['contactName'] as String,
      responseTime: DateTime.parse(json['responseTime'] as String),
      canHelp: json['canHelp'] as bool,
      message: json['message'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

/// Statut possible d'une alerte
enum AlertStatus {
  pending, // Alerte envoyée
  confirmed, // Contact a confirmé
  resolved, // Situation résolue
  falseAlarm, // Fausse alerte
  cancelled, // Annulée par l'utilisateur
  expired, // Expirée sans réponse
}
