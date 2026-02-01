import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safeguardian_ci_new/data/models/emergency_contact.dart';

// 📋 Événements pour la gestion des contacts
abstract class ContactsEvent {}

/// Charger tous les contacts
class LoadContacts extends ContactsEvent {}

/// Ajouter un nouveau contact
class AddContact extends ContactsEvent {
  final EmergencyContact contact;
  AddContact(this.contact);
}

/// Mettre à jour un contact existant
class UpdateContact extends ContactsEvent {
  final EmergencyContact contact;
  UpdateContact(this.contact);
}

/// Supprimer un contact
class DeleteContact extends ContactsEvent {
  final String id;
  DeleteContact(this.id);
}

/// Réinitialiser les données (pour le développement)
class ResetContacts extends ContactsEvent {}

// 📌 États possibles du Bloc
abstract class ContactsState {}

/// État initial (chargement en cours)
class ContactsInitial extends ContactsState {}

/// État chargé avec succès
class ContactsLoaded extends ContactsState {
  final List<EmergencyContact> contacts;
  ContactsLoaded(this.contacts);
}

/// État d'erreur
class ContactsError extends ContactsState {
  final String message;
  ContactsError(this.message);
}

/// 🧠 Bloc principal pour la gestion des contacts
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  static const String _hiveBoxName = 'safeGuardianContacts';

  ContactsBloc() : super(ContactsInitial()) {
    // Initialiser Hive si nécessaire
    _initHive();

    // Définir les gestionnaires d'événements
    on<LoadContacts>(_onLoadContacts);
    on<AddContact>(_onAddContact);
    on<UpdateContact>(_onUpdateContact);
    on<DeleteContact>(_onDeleteContact);
    on<ResetContacts>(_onResetContacts);

    // Charger les contacts au démarrage
    add(LoadContacts());
  }

  /// Initialiser Hive pour la persistance
  Future<void> _initHive() async {
    try {
      await Hive.openBox<EmergencyContact>(_hiveBoxName);
    } catch (e) {
      debugPrint('Hive initialization error: $e');
    }
  }

  /// Charger les contacts depuis Hive
  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final box = Hive.box<EmergencyContact>(_hiveBoxName);
      final contacts = box.values.toList();

      // Si la boîte est vide, ajouter des données de démonstration
      if (contacts.isEmpty) {
        await _initializeDemoData();
        add(LoadContacts()); // Recharger après ajout des données
        return;
      }

      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError('Erreur chargement: ${e.toString()}'));
    }
  }

  /// Ajouter un contact
  Future<void> _onAddContact(
    AddContact event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final box = Hive.box<EmergencyContact>(_hiveBoxName);
      await box.add(event.contact);
      final updatedContacts = box.values.toList();
      emit(ContactsLoaded(updatedContacts));
    } catch (e) {
      emit(ContactsError('Erreur ajout: ${e.toString()}'));
    }
  }

  /// Mettre à jour un contact
  Future<void> _onUpdateContact(
    UpdateContact event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final box = Hive.box<EmergencyContact>(_hiveBoxName);
      final index = box.values.toList().indexWhere(
        (c) => c.id == event.contact.id,
      );

      if (index != -1) {
        await box.putAt(index, event.contact);
        final updatedContacts = box.values.toList();
        emit(ContactsLoaded(updatedContacts));
      } else {
        emit(ContactsError('Contact non trouvé'));
      }
    } catch (e) {
      emit(ContactsError('Erreur mise à jour: ${e.toString()}'));
    }
  }

  /// Supprimer un contact
  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final box = Hive.box<EmergencyContact>(_hiveBoxName);
      final index = box.values.toList().indexWhere((c) => c.id == event.id);

      if (index != -1) {
        await box.deleteAt(index);
        final updatedContacts = box.values.toList();
        emit(ContactsLoaded(updatedContacts));
      } else {
        emit(ContactsError('Contact non trouvé'));
      }
    } catch (e) {
      emit(ContactsError('Erreur suppression: ${e.toString()}'));
    }
  }

  /// Réinitialiser les données (pour le développement)
  Future<void> _onResetContacts(
    ResetContacts event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final box = Hive.box<EmergencyContact>(_hiveBoxName);
      await box.clear();
      await _initializeDemoData();
      final updatedContacts = box.values.toList();
      emit(ContactsLoaded(updatedContacts));
    } catch (e) {
      emit(ContactsError('Erreur réinitialisation: ${e.toString()}'));
    }
  }

  /// Initialiser des données de démonstration (pour le développement)
  Future<void> _initializeDemoData() async {
    final box = Hive.box<EmergencyContact>(_hiveBoxName);
    final demoContacts = [
      EmergencyContact(
        id: '1',
        userId: 'current_user',
        name: 'Marie Kouassi',
        relationship: 'Mère',
        phone: '+225 07 08 09 10 11',
        email: 'marie.k@safeguardian.ci',
        priority: 1,
        color: const Color(0xFFEF4444),
        isVerified: true,
        canSeeLiveLocation: true,
        lastAlert: null,
        responseTime: 'N/A',
        addedDate: DateTime.now(),
      ),
      EmergencyContact(
        id: '2',
        userId: 'current_user',
        name: 'Jean-Paul Diabaté',
        relationship: 'Père',
        phone: '+225 07 12 13 14 15',
        email: 'jp.diabate@safeguardian.ci',
        priority: 1,
        color: const Color(0xFFF97316),
        isVerified: true,
        canSeeLiveLocation: true,
        lastAlert: null,
        responseTime: 'N/A',
        addedDate: DateTime.now(),
      ),
      EmergencyContact(
        id: '3',
        userId: 'current_user',
        name: 'Sophie N\'Guessan',
        relationship: 'Meilleur ami',
        phone: '+225 07 20 21 22 23',
        email: 'sophie.n@safeguardian.ci',
        priority: 2,
        color: const Color(0xFF3B82F6),
        isVerified: false,
        canSeeLiveLocation: false,
        lastAlert: null,
        responseTime: 'N/A',
        addedDate: DateTime.now(),
      ),
      EmergencyContact(
        id: '4',
        userId: 'current_user',
        name: 'Police Centrale',
        relationship: 'Police (111)',
        phone: '111',
        email: 'urgence@police.gov.ci',
        priority: 4,
        color: const Color(0xFF1E293B),
        isVerified: true,
        canSeeLiveLocation: true,
        lastAlert: null,
        responseTime: 'Immédiat',
        addedDate: DateTime.now(),
      ),
      EmergencyContact(
        id: '5',
        userId: 'current_user',
        name: 'SAMU Abidjan',
        relationship: 'SAMU (185)',
        phone: '185',
        email: 'samu@sante.gov.ci',
        priority: 4,
        color: const Color(0xFF10B981),
        isVerified: true,
        canSeeLiveLocation: true,
        lastAlert: null,
        responseTime: 'Immédiat',
        addedDate: DateTime.now(),
      ),
    ];

    for (final contact in demoContacts) {
      await box.add(contact);
    }
  }
}
