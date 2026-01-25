import 'package:flutter/material.dart';

class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final int priority;
  final Color color;
  final bool isVerified;
  final bool canSeeLiveLocation;
  final DateTime? lastAlert;
  final String responseTime;
  final DateTime addedDate;
  final String? notes;

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.priority,
    required this.color,
    required this.isVerified,
    required this.canSeeLiveLocation,
    this.lastAlert,
    required this.responseTime,
    required this.addedDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'priority': priority,
      'color': color,
      'isVerified': isVerified,
      'canSeeLiveLocation': canSeeLiveLocation,
      'lastAlert': lastAlert?.toIso8601String(),
      'responseTime': responseTime,
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      relationship: json['relationship'],
      priority: json['priority'],
      color: json['color'],
      isVerified: json['isVerified'],
      canSeeLiveLocation: json['canSeeLiveLocation'],
      lastAlert: json['lastAlert'] != null
          ? DateTime.parse(json['lastAlert'])
          : null,
      responseTime: json['responseTime'],
      addedDate: DateTime.parse(json['addedDate']),
      notes: json['notes'],
    );
  }

  EmergencyContact copyWith({
    int? priority,
    bool? canSeeLiveLocation,
    bool? isVerified,
    String? responseTime,
    DateTime? lastAlert,
  }) {
    return EmergencyContact(
      id: id,
      userId: userId,
      name: name,
      relationship: relationship,
      phone: phone,
      email: email,
      priority: priority ?? this.priority,
      color: color,
      isVerified: isVerified ?? this.isVerified,
      canSeeLiveLocation: canSeeLiveLocation ?? this.canSeeLiveLocation,
      lastAlert: lastAlert ?? this.lastAlert,
      responseTime: responseTime ?? this.responseTime,
      addedDate: addedDate,
      notes: notes,
    );
  }
}
