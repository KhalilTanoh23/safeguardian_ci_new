// lib/data/models/document.dart

class OfficialDocument {
  final String id;
  final String userId;
  final DocumentType type;
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String? photoFrontPath;
  final String? photoBackPath;
  final DateTime addedDate;
  final bool isLost;
  final DateTime? reportedLostDate;
  final String? qrCode;

  OfficialDocument({
    required this.id,
    required this.userId,
    required this.type,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.photoFrontPath,
    this.photoBackPath,
    required this.addedDate,
    this.isLost = false,
    this.reportedLostDate,
    this.qrCode,
  });

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'documentNumber': documentNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'issuingAuthority': issuingAuthority,
      'photoFrontPath': photoFrontPath,
      'photoBackPath': photoBackPath,
      'addedDate': addedDate.toIso8601String(),
      'isLost': isLost,
      'reportedLostDate': reportedLostDate?.toIso8601String(),
      'qrCode': qrCode,
    };
  }

  factory OfficialDocument.fromJson(Map<String, dynamic> json) {
    return OfficialDocument(
      id: json['id'],
      userId: json['userId'],
      type: DocumentType.values.firstWhere((e) => e.name == json['type']),
      documentNumber: json['documentNumber'],
      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      issuingAuthority: json['issuingAuthority'],
      photoFrontPath: json['photoFrontPath'],
      photoBackPath: json['photoBackPath'],
      addedDate: DateTime.parse(json['addedDate']),
      isLost: json['isLost'],
      reportedLostDate: json['reportedLostDate'] != null
          ? DateTime.parse(json['reportedLostDate'])
          : null,
      qrCode: json['qrCode'],
    );
  }
}

enum DocumentType {
  idCard, // Carte d'identité
  passport, // Passeport
  driverLicense, // Permis de conduire
  studentCard, // Carte d'étudiant
  birthCertificate, // Acte de naissance
  other, // Autre document
}
