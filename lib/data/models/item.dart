import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Objet possédé par un utilisateur et pouvant être perdu
class ValuedItem extends Equatable {
  final String id;
  final String userId;
  final String name;
  final ItemCategory category;
  final double estimatedValue;
  final String description;
  final String? photoPath;
  final DateTime addedDate;
  final bool isLost;
  final DateTime? lostDate;
  final LatLng? lostLocation;
  final String? qrCode;
  final List<String> tags;

  const ValuedItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.estimatedValue,
    required this.description,
    this.photoPath,
    required this.addedDate,
    this.isLost = false,
    this.lostDate,
    this.lostLocation,
    this.qrCode,
    this.tags = const [],
  });

  ValuedItem copyWith({
    String? id,
    String? userId,
    String? name,
    ItemCategory? category,
    double? estimatedValue,
    String? description,
    String? photoPath,
    DateTime? addedDate,
    bool? isLost,
    DateTime? lostDate,
    LatLng? lostLocation,
    String? qrCode,
    List<String>? tags,
  }) {
    return ValuedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      addedDate: addedDate ?? this.addedDate,
      isLost: isLost ?? this.isLost,
      lostDate: lostDate ?? this.lostDate,
      lostLocation: lostLocation ?? this.lostLocation,
      qrCode: qrCode ?? this.qrCode,
      tags: tags ?? this.tags,
    );
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'category': category.name,
    'estimatedValue': estimatedValue,
    'description': description,
    'photoPath': photoPath,
    'addedDate': addedDate.toIso8601String(),
    'isLost': isLost,
    'lostDate': lostDate?.toIso8601String(),
    'lostLocation': lostLocation != null
        ? {
            'latitude': lostLocation!.latitude,
            'longitude': lostLocation!.longitude,
          }
        : null,
    'qrCode': qrCode,
    'tags': tags,
  };

  /// Création d'un objet à partir d'un JSON (défensif)
  factory ValuedItem.fromJson(Map<String, dynamic> json) {
    String parseString(Object? v, [String fallback = '']) {
      if (v == null) return fallback;
      return v is String ? v : v.toString();
    }

    double parseDouble(Object? v, [double fallback = 0.0]) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s) ?? fallback;
    }

    DateTime parseDate(Object? v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final dt = DateTime.tryParse(v);
        return dt ?? DateTime.now();
      }
      return DateTime.now();
    }

    LatLng? parseLocation(Object? v) {
      if (v == null) return null;
      if (v is LatLng) return v;
      if (v is Map) {
        try {
          final lat = (v['latitude'] as num).toDouble();
          final lng = (v['longitude'] as num).toDouble();
          return LatLng(lat, lng);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final categoryName = parseString(json['category'], ItemCategory.other.name);
    final category = ItemCategory.values.firstWhere(
      (e) => e.name == categoryName,
      orElse: () => ItemCategory.other,
    );

    return ValuedItem(
      id: parseString(json['id']),
      userId: parseString(json['userId']),
      name: parseString(json['name']),
      category: category,
      estimatedValue: parseDouble(json['estimatedValue']),
      description: parseString(json['description']),
      photoPath: json['photoPath'] is String
          ? json['photoPath'] as String
          : null,
      addedDate: parseDate(json['addedDate']),
      isLost: (json['isLost'] is bool)
          ? json['isLost'] as bool
          : (json['isLost'] != null && json['isLost'].toString() == 'true'),
      lostDate: json['lostDate'] != null
          ? DateTime.tryParse(json['lostDate'].toString())
          : null,
      lostLocation: parseLocation(json['lostLocation']),
      qrCode: json['qrCode'] is String ? json['qrCode'] as String : null,
      tags: (json['tags'] is List)
          ? List<String>.from((json['tags'] as List).map((e) => e.toString()))
          : [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    category,
    estimatedValue,
    isLost,
  ];

  @override
  String toString() =>
      'ValuedItem(id: $id, name: $name, category: ${category.name})';
}

/// Catégorie de l'objet
/// Note: expanded to match categories used in UI (accessories, clothing, etc).
enum ItemCategory {
  electronics,
  jewelry,
  documents,
  keys,
  wallet,
  accessories,
  clothing,
  other,
}

/// Objet trouvé par un utilisateur et pouvant être réclamé
class FoundItem extends Equatable {
  final String id;
  final String finderId;
  final String finderName;
  final String itemName;
  final ItemCategory category;
  final String description;
  final String? photoPath;
  final LatLng foundLocation;
  final DateTime foundDate;
  final String? contactInfo;
  final bool isClaimed;
  final String? claimedBy;

  const FoundItem({
    required this.id,
    required this.finderId,
    required this.finderName,
    required this.itemName,
    required this.category,
    required this.description,
    this.photoPath,
    required this.foundLocation,
    required this.foundDate,
    this.contactInfo,
    this.isClaimed = false,
    this.claimedBy,
  });

  FoundItem copyWith({
    String? id,
    String? finderId,
    String? finderName,
    String? itemName,
    ItemCategory? category,
    String? description,
    String? photoPath,
    LatLng? foundLocation,
    DateTime? foundDate,
    String? contactInfo,
    bool? isClaimed,
    String? claimedBy,
  }) {
    return FoundItem(
      id: id ?? this.id,
      finderId: finderId ?? this.finderId,
      finderName: finderName ?? this.finderName,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      foundLocation: foundLocation ?? this.foundLocation,
      foundDate: foundDate ?? this.foundDate,
      contactInfo: contactInfo ?? this.contactInfo,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedBy: claimedBy ?? this.claimedBy,
    );
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'finderId': finderId,
    'finderName': finderName,
    'itemName': itemName,
    'category': category.name,
    'description': description,
    'photoPath': photoPath,
    'foundLocation': {
      'latitude': foundLocation.latitude,
      'longitude': foundLocation.longitude,
    },
    'foundDate': foundDate.toIso8601String(),
    'contactInfo': contactInfo,
    'isClaimed': isClaimed,
    'claimedBy': claimedBy,
  };

  /// Création à partir d'un JSON (défensif)
  factory FoundItem.fromJson(Map<String, dynamic> json) {
    String parseString(Object? v, [String fallback = '']) {
      if (v == null) return fallback;
      return v is String ? v : v.toString();
    }

    final categoryName = parseString(json['category'], ItemCategory.other.name);
    final category = ItemCategory.values.firstWhere(
      (e) => e.name == categoryName,
      orElse: () => ItemCategory.other,
    );

    final loc = json['foundLocation'];
    LatLng parseLocation(Object? v) {
      if (v is LatLng) return v;
      if (v is Map) {
        final lat = (v['latitude'] as num).toDouble();
        final lng = (v['longitude'] as num).toDouble();
        return LatLng(lat, lng);
      }
      throw ArgumentError('Invalid foundLocation');
    }

    return FoundItem(
      id: parseString(json['id']),
      finderId: parseString(json['finderId']),
      finderName: parseString(json['finderName']),
      itemName: parseString(json['itemName']),
      category: category,
      description: parseString(json['description']),
      photoPath: json['photoPath'] is String
          ? json['photoPath'] as String
          : null,
      foundLocation: parseLocation(loc),
      foundDate:
          DateTime.tryParse(parseString(json['foundDate'])) ?? DateTime.now(),
      contactInfo: json['contactInfo'] is String
          ? json['contactInfo'] as String
          : null,
      isClaimed: (json['isClaimed'] is bool)
          ? json['isClaimed'] as bool
          : (json['isClaimed'] != null &&
                json['isClaimed'].toString() == 'true'),
      claimedBy: json['claimedBy'] is String
          ? json['claimedBy'] as String
          : null,
    );
  }

  @override
  List<Object?> get props => [id, itemName, category, foundLocation, isClaimed];

  @override
  String toString() =>
      'FoundItem(id: $id, itemName: $itemName, category: ${category.name})';
}
