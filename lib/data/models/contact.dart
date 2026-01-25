// lib/data/models/contact.dart

class Contact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String relationship;
  final bool isEmergencyContact;
  final DateTime addedDate;
  final String? notes;
  final int priority; // 1 = haute priorité, 3 = basse priorité

  Contact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
    this.isEmergencyContact = true,
    required this.addedDate,
    this.notes,
    this.priority = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'isEmergencyContact': isEmergencyContact,
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
      'priority': priority,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      relationship: json['relationship'],
      isEmergencyContact: json['isEmergencyContact'],
      addedDate: DateTime.parse(json['addedDate']),
      notes: json['notes'],
      priority: json['priority'],
    );
  }
}
