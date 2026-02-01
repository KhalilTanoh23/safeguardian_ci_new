import 'package:flutter/material.dart';
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

class AuthUpdateProfileRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String? phone;

  const AuthUpdateProfileRequested({
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object> get props => [firstName, lastName, if (phone != null) phone!];
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
  final ApiService? apiService;

  AuthBloc({required this.firebaseAvailable, this.apiService})
    : super(AuthInitial()) {
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateSettingsRequested>(_onAuthUpdateSettingsRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);

    // Ajout des handlers Google / Apple
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthAppleLoginRequested>(_onAuthAppleLoginRequested);
  }

  // Vérification statut
  Future<void> _onAuthCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final apiService = this.apiService ?? ApiService();
      final token = await apiService.getToken();

      if (token != null && token.isNotEmpty) {
        // Token exists, try to get user profile
        try {
          final profileResponse = await apiService.getProfile();

          // Convertir le rôle string en UserRole enum
          UserRole roleEnum = UserRole.user;
          if (profileResponse['role'] != null) {
            try {
              roleEnum = UserRole.values.firstWhere(
                (role) => role.name == profileResponse['role'],
                orElse: () => UserRole.user,
              );
            } catch (e) {
              roleEnum = UserRole.user;
            }
          }

          // Convertir le statut string en UserStatus enum
          UserStatus statusEnum = UserStatus.active;
          if (profileResponse['status'] != null) {
            try {
              statusEnum = UserStatus.values.firstWhere(
                (status) => status.name == profileResponse['status'],
                orElse: () => UserStatus.active,
              );
            } catch (e) {
              statusEnum = UserStatus.active;
            }
          }

          // Créer l'utilisateur à partir du profil
          final user = User(
            id: profileResponse['id']?.toString() ?? '',
            email: profileResponse['email'] ?? '',
            phone: profileResponse['phone'] ?? '',
            firstName: profileResponse['firstName'] ?? '',
            lastName: profileResponse['lastName'] ?? '',
            profileImage: profileResponse['profileImage'],
            createdAt: profileResponse['createdAt'] != null
                ? DateTime.parse(profileResponse['createdAt'])
                : DateTime.now(),
            status: statusEnum,
            roles: [roleEnum],
            settings: UserSettings(), // TODO: Load from API when available
            emergencyInfo: EmergencyInfo(),
          );

          emit(AuthAuthenticated(user));
        } catch (profileError) {
          // Token existe mais le profil ne peut pas être récupéré
          // Le token est peut-être expiré ou invalide
          debugPrint('❌ Impossible de récupérer le profil: $profileError');
          await apiService.removeToken();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If token check fails, clear token and unauthenticate
      debugPrint('❌ Erreur vérification statut auth: $e');
      final apiService = this.apiService ?? ApiService();
      await apiService.removeToken();
      emit(AuthUnauthenticated());
    }
  }

  // Login classique
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError('Email et mot de passe requis'));
        return;
      }

      final apiService = this.apiService ?? ApiService();
      final response = await apiService.login(event.email, event.password);

      // Créer l'utilisateur à partir de la réponse API
      final userData = response['user'];

      // Convertir le rôle string en UserRole enum
      UserRole roleEnum = UserRole.user;
      if (userData['role'] != null) {
        try {
          roleEnum = UserRole.values.firstWhere(
            (role) => role.name == userData['role'],
            orElse: () => UserRole.user,
          );
        } catch (e) {
          roleEnum = UserRole.user;
        }
      }

      final user = User(
        id: userData['id']?.toString() ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        firstName: userData['firstName'] ?? userData['first_name'] ?? '',
        lastName: userData['lastName'] ?? userData['last_name'] ?? '',
        createdAt: DateTime.now(),
        status: UserStatus.active,
        roles: [roleEnum],
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
      if (event.email.isEmpty ||
          event.password.isEmpty ||
          event.fullName.isEmpty) {
        emit(const AuthError('Tous les champs sont requis'));
        return;
      }

      final names = event.fullName.split(' ');
      final firstName = names.isNotEmpty ? names.first : 'Utilisateur';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final apiService = this.apiService ?? ApiService();
      final response = await apiService.register(
        email: event.email,
        password: event.password,
        firstName: firstName,
        lastName: lastName,
        phone: '', // Phone will be empty for now, can be updated later
      );

      // Créer l'utilisateur à partir de la réponse API
      final userData = response['user'];

      // Convertir le rôle string en UserRole enum
      UserRole roleEnum = UserRole.user;
      if (userData['role'] != null) {
        try {
          roleEnum = UserRole.values.firstWhere(
            (role) => role.name == userData['role'],
            orElse: () => UserRole.user,
          );
        } catch (e) {
          roleEnum = UserRole.user;
        }
      }

      final user = User(
        id: userData['id']?.toString() ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        firstName: userData['firstName'] ?? userData['first_name'] ?? firstName,
        lastName: userData['lastName'] ?? userData['last_name'] ?? lastName,
        createdAt: DateTime.now(),
        status: UserStatus.active,
        roles: [roleEnum],
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
      final apiService = this.apiService ?? ApiService();
      await apiService.logout(); // This clears the token from storage
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
        final apiService = this.apiService ?? ApiService();
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

  // Update user profile
  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        // Call the API to update user profile
        final apiService = this.apiService ?? ApiService();
        final response = await apiService.updateProfile(
          firstName: event.firstName,
          lastName: event.lastName,
          phone: event.phone,
        );

        // Update the user with the response from the API
        final updatedUser = User(
          id: currentState.user.id,
          email: currentState.user.email,
          phone: response['phone'],
          firstName: response['firstName'],
          lastName: response['lastName'],
          profileImage: currentState.user.profileImage,
          createdAt: currentState.user.createdAt,
          status: currentState.user.status,
          roles: currentState.user.roles,
          settings: currentState.user.settings,
          emergencyInfo: currentState.user.emergencyInfo,
        );

        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }
}
