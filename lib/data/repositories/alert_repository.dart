import 'dart:async';

import 'package:hive/hive.dart';
import 'package:safeguardian_ci_new/data/models/alert.dart';

/// Repository pour stocker / lire les EmergencyAlert dans Hive.
///
/// IMPORTANT:
/// - Assure-toi d'avoir enregistré un TypeAdapter pour EmergencyAlert (et
///   pour les types imbriqués si nécessaire) avant d'utiliser ce repository.
///   Par exemple, dans `main()` :
///     Hive.registerAdapter(EmergencyAlertAdapter());
///     // register autres adapters...
///     await Hive.initFlutter(...);
///
/// - Ce repository ouvre la box de façon paresseuse (lazy) et la réutilise.
class AlertRepository {
  static const String _boxName = 'alerts';

  // Singleton
  AlertRepository._internal();
  static final AlertRepository _instance = AlertRepository._internal();
  factory AlertRepository() => _instance;

  Box<EmergencyAlert>? _box;

  Future<Box<EmergencyAlert>> _ensureBoxOpen() async {
    if (_box != null && _box!.isOpen) return _box!;

    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<EmergencyAlert>(_boxName);
      return _box!;
    }

    try {
      _box = await Hive.openBox<EmergencyAlert>(_boxName);
      return _box!;
    } catch (e, st) {
      // Rethrow or wrap if you want a custom exception type.
      // For now, log and rethrow to let the caller handle it.
      // ignore: avoid_print
      print('Erreur ouverture box $_boxName: $e\n$st');
      rethrow;
    }
  }

  /// Retourne la liste d'alertes pour un utilisateur, triée par timestamp descendant.
  Future<List<EmergencyAlert>> getAlertsForUser(String userId) async {
    try {
      final box = await _ensureBoxOpen();
      final alerts = box.values
          .where((alert) => alert.userId == userId)
          .toList();
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return List<EmergencyAlert>.unmodifiable(alerts);
    } catch (e, st) {
      // ignore: avoid_print
      print('getAlertsForUser error: $e\n$st');
      rethrow; // Propager l'erreur au lieu de retourner une liste vide
    }
  }

  /// Récupère une alerte par son id (clé de la box).
  Future<EmergencyAlert?> getAlertById(String id) async {
    try {
      final box = await _ensureBoxOpen();
      return box.get(
        id,
      ); // Pas besoin de cast, le type est déjà Box<EmergencyAlert>
    } catch (e, st) {
      // ignore: avoid_print
      print('getAlertById error: $e\n$st');
      rethrow; // Propager l'erreur
    }
  }

  /// Enregistre (ou remplace) une alerte.
  Future<void> saveAlert(EmergencyAlert alert) async {
    if (alert.id.isEmpty) {
      throw ArgumentError('Alert id cannot be empty');
    }
    try {
      final box = await _ensureBoxOpen();
      await box.put(alert.id, alert);
    } catch (e, st) {
      // ignore: avoid_print
      print('saveAlert error: $e\n$st');
      rethrow;
    }
  }

  /// Met à jour une alerte (alias put).
  Future<void> updateAlert(EmergencyAlert alert) async {
    await saveAlert(alert);
  }

  /// Supprime une alerte par id.
  Future<void> deleteAlert(String id) async {
    try {
      final box = await _ensureBoxOpen();
      await box.delete(id);
    } catch (e, st) {
      // ignore: avoid_print
      print('deleteAlert error: $e\n$st');
      rethrow;
    }
  }

  /// Dernières alertes (limit), triées par timestamp descendant.
  Future<List<EmergencyAlert>> getRecentAlerts(
    String userId, {
    int limit = 10,
  }) async {
    final alerts = await getAlertsForUser(userId);
    if (alerts.length <= limit) return alerts;
    return alerts.take(limit).toList();
  }

  /// Retourne un stream qui émet la liste d'alertes de l'utilisateur à chaque
  /// changement dans la box (initial + updates).
  Stream<List<EmergencyAlert>> watchAlertsForUser(String userId) async* {
    final box = await _ensureBoxOpen();

    // Emission initiale
    final initial = box.values.where((a) => a.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    yield List<EmergencyAlert>.unmodifiable(initial);

    // Puis on écoute les changements
    await for (final _ in box.watch()) {
      final list = box.values.where((a) => a.userId == userId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      yield List<EmergencyAlert>.unmodifiable(list);
    }
  }

  /// Vide toutes les alertes (utilitaire).
  Future<void> clearAllAlerts() async {
    try {
      final box = await _ensureBoxOpen();
      await box.clear();
    } catch (e, st) {
      // ignore: avoid_print
      print('clearAllAlerts error: $e\n$st');
      rethrow;
    }
  }

  /// Ferme la box (appelable au shutdown si nécessaire).
  Future<void> close() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
      } else if (Hive.isBoxOpen(_boxName)) {
        await Hive.box<EmergencyAlert>(_boxName).close();
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('close box error: $e\n$st');
    }
  }
}
