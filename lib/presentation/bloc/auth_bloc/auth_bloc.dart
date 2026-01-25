import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user.dart';
import '../../../core/services/api_service.dart';

// ===================== EVENTS =====================
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckStatus extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const AuthRegisterRequested(this.email, this.password, this.fullName);

  @override
  List<Object> get props => [email, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateSettingsRequested extends AuthEvent {
  final Map<String, dynamic> settings;

  const AuthUpdateSettingsRequested(this.settings);

  @override
  List<Object> get props => [settings];
}

// ======= NOUVEAUX EVENTS GOOGLE / APPLE =======
class AuthGoogleLoginRequested extends AuthEvent {}

class AuthAppleLoginRequested extends AuthEvent {}

// ===================== STATES =====================
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// ===================== BLOC =====================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final bool firebaseAvailable;

  AuthBloc({required this.firebaseAvailable}) : super(AuthInitial()) {
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateSettingsRequested>(_onAuthUpdateSettingsRequested);

    // Ajout des handlers Google / Apple
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthAppleLoginRequested>(_onAuthAppleLoginRequested);
  }

  // Vérification statut
  Future<void> _onAuthCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  // Login classique
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError('Email et mot de passe requis'));
        return;
      }

      final parts = event.email.split('@');
      final firstName = parts.isNotEmpty && parts[0].isNotEmpty
          ? parts[0].split('.').first
          : 'Utilisateur';
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: event.email,
        phone: '',
        firstName: firstName,
        lastName: '',
        createdAt: DateTime.now(),
        settings: UserSettings(),
        emergencyInfo: EmergencyInfo(),
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Register
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (event.email.isEmpty ||
          event.password.isEmpty ||
          event.fullName.isEmpty) {
        emit(const AuthError('Tous les champs sont requis'));
        return;
      }

      final names = event.fullName.split(' ');
      final firstName = names.isNotEmpty ? names.first : 'Utilisateur';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: event.email,
        phone: '',
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        settings: UserSettings(),
        emergencyInfo: EmergencyInfo(),
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Logout
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // LOGIN GOOGLE MOCK
  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User(
      id: "google_${DateTime.now().millisecondsSinceEpoch}",
      email: "google_user@gmail.com",
      phone: '',
      firstName: "Google",
      lastName: "User",
      createdAt: DateTime.now(),
      settings: UserSettings(),
      emergencyInfo: EmergencyInfo(),
    );

    emit(AuthAuthenticated(user));
  }

  // LOGIN APPLE MOCK
  Future<void> _onAuthAppleLoginRequested(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User(
      id: "apple_${DateTime.now().millisecondsSinceEpoch}",
      email: "apple_user@icloud.com",
      phone: '',
      firstName: "Apple",
      lastName: "User",
      createdAt: DateTime.now(),
      settings: UserSettings(),
      emergencyInfo: EmergencyInfo(),
    );

    emit(AuthAuthenticated(user));
  }

  // Update user settings
  Future<void> _onAuthUpdateSettingsRequested(
    AuthUpdateSettingsRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        // Call the API to update user settings
        final apiService = ApiService();
        final response = await apiService.updateUserSettings(event.settings);

        // Update the user with the response from the API
        final updatedUser = User(
          id: currentState.user.id,
          email: currentState.user.email,
          phone: currentState.user.phone,
          firstName: currentState.user.firstName,
          lastName: currentState.user.lastName,
          profileImage: currentState.user.profileImage,
          createdAt: currentState.user.createdAt,
          status: currentState.user.status,
          roles: currentState.user.roles,
          settings: UserSettings(
            notificationsEnabled:
                response['notificationsEnabled'] ??
                currentState.user.settings.notificationsEnabled,
            biometricAuth:
                response['biometricAuth'] ??
                currentState.user.settings.biometricAuth,
            locationSharing:
                response['locationSharing'] ??
                currentState.user.settings.locationSharing,
            discreetMode:
                response['discreetMode'] ??
                currentState.user.settings.discreetMode,
            autoConnectBracelet:
                response['autoConnectBracelet'] ??
                currentState.user.settings.autoConnectBracelet,
            communityAlertsEnabled:
                currentState.user.settings.communityAlertsEnabled,
            communityRadius: currentState.user.settings.communityRadius,
            language: currentState.user.settings.language,
            darkMode: currentState.user.settings.darkMode,
            emergencyTimeout: currentState.user.settings.emergencyTimeout,
          ),
          emergencyInfo: currentState.user.emergencyInfo,
        );

        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }
}
