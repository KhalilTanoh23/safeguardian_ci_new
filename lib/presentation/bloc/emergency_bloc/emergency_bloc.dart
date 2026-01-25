import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/alert.dart';

/// Simple abstract interfaces so the bloc is independent from implementation.
/// Implement these in your data layer and pass concrete instances to the bloc.
abstract class EmergencyRepository {
  /// Create an alert on the backend and return the created alert (with id, etc).
  Future<EmergencyAlert> createAlert({
    required String userId,
    required String userName,
    required String message,
    required LatLng location,
  });

  /// Cancel an alert on the backend.
  Future<void> cancelAlert({required String alertId, required String reason});

  /// Send a community alert (e.g. broadcast) — return updated alert if desired.
  Future<void> sendCommunityAlert({required EmergencyAlert alert});
}

abstract class LocationService {
  /// Return the current device location. Throw if unavailable/permission denied.
  Future<LatLng> getCurrentLocation();
}

// Events
abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object> get props => [];
}

class EmergencyTriggered extends EmergencyEvent {
  final String userId;
  final String userName;
  final String message;

  const EmergencyTriggered({
    required this.userId,
    required this.userName,
    required this.message,
  });

  @override
  List<Object> get props => [userId, userName, message];
}

class EmergencyCancelled extends EmergencyEvent {
  final String alertId;
  final String reason;

  const EmergencyCancelled({required this.alertId, required this.reason});

  @override
  List<Object> get props => [alertId, reason];
}

class CommunityAlertSent extends EmergencyEvent {
  final EmergencyAlert alert;

  const CommunityAlertSent({required this.alert});

  @override
  List<Object> get props => [alert.id];
}

// States
abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyLoading extends EmergencyState {}

class EmergencyAlertActive extends EmergencyState {
  final EmergencyAlert alert;

  const EmergencyAlertActive(this.alert);

  // Compare by id to avoid issues if EmergencyAlert doesn't implement Equatable.
  @override
  List<Object> get props => [alert.id];
}

class EmergencyAlertCancelled extends EmergencyState {
  final String alertId;

  const EmergencyAlertCancelled(this.alertId);

  @override
  List<Object> get props => [alertId];
}

class EmergencySuccess extends EmergencyState {
  final String message;

  const EmergencySuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EmergencyError extends EmergencyState {
  final String message;

  const EmergencyError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final EmergencyRepository repository;
  final LocationService locationService;

  // Simple in-flight guard to prevent multiple concurrent triggers/cancels.
  bool _inProgress = false;

  EmergencyBloc({required this.repository, required this.locationService})
    : super(EmergencyInitial()) {
    on<EmergencyTriggered>(_onEmergencyTriggered);
    on<EmergencyCancelled>(_onEmergencyCancelled);
    on<CommunityAlertSent>(_onCommunityAlertSent);
  }

  Future<void> _onEmergencyTriggered(
    EmergencyTriggered event,
    Emitter<EmergencyState> emit,
  ) async {
    if (_inProgress) {
      emit(const EmergencyError('Une opération est déjà en cours'));
      return;
    }
    _inProgress = true;
    emit(EmergencyLoading());

    try {
      // Get the current device location (could throw if permissions denied).
      final LatLng location = await locationService.getCurrentLocation();

      // Create the alert using repository (backend). Repository should return created alert with id.
      final EmergencyAlert alert = await repository.createAlert(
        userId: event.userId,
        userName: event.userName,
        message: event.message,
        location: location,
      );

      emit(EmergencyAlertActive(alert));
    } catch (e) {
      // Log stack if you have logging available.
      emit(EmergencyError('Erreur lors de la création de l\'alerte: $e'));
    } finally {
      _inProgress = false;
    }
  }

  Future<void> _onEmergencyCancelled(
    EmergencyCancelled event,
    Emitter<EmergencyState> emit,
  ) async {
    if (_inProgress) {
      emit(const EmergencyError('Une opération est déjà en cours'));
      return;
    }
    _inProgress = true;
    emit(EmergencyLoading());

    try {
      await repository.cancelAlert(
        alertId: event.alertId,
        reason: event.reason,
      );
      emit(EmergencyAlertCancelled(event.alertId));
    } catch (e) {
      emit(EmergencyError('Erreur lors de l\'annulation: $e'));
    } finally {
      _inProgress = false;
    }
  }

  Future<void> _onCommunityAlertSent(
    CommunityAlertSent event,
    Emitter<EmergencyState> emit,
  ) async {
    // sending community alert is a side-effect; we still catch errors and optionally emit states
    try {
      await repository.sendCommunityAlert(alert: event.alert);
      emit(const EmergencySuccess('Alerte communautaire envoyée'));
    } catch (e) {
      emit(EmergencyError('Erreur envoi alerte communauté: $e'));
    }
  }
}
