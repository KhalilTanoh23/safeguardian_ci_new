import 'dart:async';

import 'package:hive/hive.dart';
import 'package:safeguardian_ci_new/data/models/contact.dart';

/// Repository pour gérer les contacts utilisateur dans Hive.
///
/// IMPORTANT:
/// - Enregistre un TypeAdapter pour `Contact` avant d'utiliser ce repository:
///     Hive.registerAdapter(ContactAdapter());
/// - Si vous utilisez Flutter, appelez `await Hive.initFlutter()` dans main()
///   (package hive_flutter).
class ContactRepository {
  static const String _boxName = 'contacts';

  ContactRepository._internal();
  static final ContactRepository _instance = ContactRepository._internal();
  factory ContactRepository() => _instance;

  Box<Contact>? _box;

  Future<Box<Contact>> _ensureBoxOpen() async {
    if (_box != null && _box!.isOpen) return _box!;

    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Contact>(_boxName);
      return _box!;
    }

    try {
      _box = await Hive.openBox<Contact>(_boxName);
      return _box!;
    } catch (e, st) {
      // ignore: avoid_print
      print('Erreur ouverture box $_boxName: $e\n$st');
      rethrow;
    }
  }

  /// Retourne la liste des contacts de l'utilisateur triés par priorité croissante.
  Future<List<Contact>> getContactsForUser(String userId) async {
    try {
      final box = await _ensureBoxOpen();
      final contacts = box.values
          .cast<Contact>()
          .where((c) => c.userId == userId)
          .toList();
      contacts.sort((a, b) => a.priority.compareTo(b.priority));
      return List<Contact>.unmodifiable(contacts);
    } catch (e, st) {
      // ignore: avoid_print
      print('getContactsForUser error: $e\n$st');
      return <Contact>[];
    }
  }

  /// Contacts marqués comme contacts d'urgence pour l'utilisateur.
  Future<List<Contact>> getEmergencyContacts(String userId) async {
    final contacts = await getContactsForUser(userId);
    return contacts.where((c) => c.isEmergencyContact).toList();
  }

  Future<Contact?> getContactById(String id) async {
    try {
      final box = await _ensureBoxOpen();
      return box.get(id);
    } catch (e, st) {
      // ignore: avoid_print
      print('getContactById error: $e\n$st');
      return null;
    }
  }

  Future<void> saveContact(Contact contact) async {
    if (contact.id.isEmpty) {
      throw ArgumentError('Contact id cannot be empty');
    }
    try {
      final box = await _ensureBoxOpen();
      await box.put(contact.id, contact);
    } catch (e, st) {
      // ignore: avoid_print
      print('saveContact error: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateContact(Contact contact) async {
    await saveContact(contact);
  }

  Future<void> deleteContact(String id) async {
    try {
      final box = await _ensureBoxOpen();
      await box.delete(id);
    } catch (e, st) {
      // ignore: avoid_print
      print('deleteContact error: $e\n$st');
      rethrow;
    }
  }

  /// Stream qui émet la liste des contacts de l'utilisateur à chaque changement.
  Stream<List<Contact>> watchContactsForUser(String userId) async* {
    final box = await _ensureBoxOpen();

    // Emission initiale
    final initial =
        box.values.cast<Contact>().where((c) => c.userId == userId).toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));
    yield List<Contact>.unmodifiable(initial);

    // Écoute les changements
    await for (final _ in box.watch()) {
      final list =
          box.values.cast<Contact>().where((c) => c.userId == userId).toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));
      yield List<Contact>.unmodifiable(list);
    }
  }

  /// Vide tous les contacts (utilitaire).
  Future<void> clearAllContacts() async {
    try {
      final box = await _ensureBoxOpen();
      await box.clear();
    } catch (e, st) {
      // ignore: avoid_print
      print('clearAllContacts error: $e\n$st');
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
        await Hive.box(_boxName).close();
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('close box error: $e\n$st');
    }
  }
}
