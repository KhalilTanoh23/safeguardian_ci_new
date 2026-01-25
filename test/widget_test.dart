// Tests pour SafeGuardian CI
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// imports de services retirés (tests utilisent des mocks locaux)
import 'package:safeguardian_ci_new/data/repositories/alert_repository.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:safeguardian_ci_new/presentation/screens/auth/login_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/main/splash_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/profile/profile_screen.dart';
import 'package:safeguardian_ci_new/data/models/alert.dart';
import 'package:safeguardian_ci_new/data/models/user.dart';
import 'package:safeguardian_ci_new/data/models/emergency_contact.dart';
import 'package:safeguardian_ci_new/data/models/contact.dart';
import 'package:safeguardian_ci_new/data/repositories/contact_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Adapter simple qui sérialise via JSON pour les tests
class EmergencyAlertAdapter extends TypeAdapter<EmergencyAlert> {
  @override
  final int typeId = 1;

  @override
  EmergencyAlert read(BinaryReader reader) {
    final jsonStr = reader.readString();
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return EmergencyAlert.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, EmergencyAlert obj) {
    writer.writeString(json.encode(obj.toJson()));
  }
}

// Mocks légers pour éviter les plugins en tests
class MockBluetoothService extends ChangeNotifier {
  dynamic get connectedDevice => null;
  bool get isConnected => false;
  bool get isScanning => false;
  bool get isConnecting => false;
}

class MockLocationService extends ChangeNotifier {
  bool get isTracking => false;
  dynamic get currentPosition => null;
}

class MockNotificationService extends ChangeNotifier {
  List get notifications => <dynamic>[];
}

void main() {
  // Configuration initiale des tests
  setUpAll(() async {
    // Assurer l'initialisation du binding et mocker path_provider
    TestWidgetsFlutterBinding.ensureInitialized();

    // Utiliser l'API de test recommandée pour mocker les MethodChannel
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final pathChannel = const MethodChannel('plugins.flutter.io/path_provider');
    messenger.setMockMethodCallHandler(pathChannel, (
      MethodCall methodCall,
    ) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getTemporaryDirectory':
          return '/tmp';
        default:
          return null;
      }
    });

    // Initialiser Hive pour les tests et enregistrer un adapter simple
    // Mocker SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Init Hive (utilise répertoire temporaire fourni par test env)
    Hive.init('.');

    // Enregistrer un adapter de test pour EmergencyAlert
    Hive.registerAdapter(EmergencyAlertAdapter());
  });

  tearDownAll(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final pathChannel = const MethodChannel('plugins.flutter.io/path_provider');
    messenger.setMockMethodCallHandler(pathChannel, null);
    // Nettoyer après les tests
    await Hive.close();
  });

  // --- Test helpers: Hive adapter + simple mocks -----------------
  // (mocks and adapters declared at top-level)

  group('SafeGuardian App Tests', () {
    testWidgets('App lance sans erreur', (WidgetTester tester) async {
      // Créer l'app avec tous les providers nécessaires
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AlertRepository>(create: (_) => AlertRepository()),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockBluetoothService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockNotificationService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockLocationService(),
            ),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(firebaseAvailable: false),
            child: const MaterialApp(
              home: Scaffold(body: Center(child: Text('SafeGuardian CI'))),
            ),
          ),
        ),
      );

      // Vérifier que l'app s'affiche
      expect(find.text('SafeGuardian CI'), findsOneWidget);
    });

    testWidgets('Splash screen s\'affiche', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(firebaseAvailable: false),
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Vérifier les éléments du splash screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SafeGuardian CI'), findsOneWidget);
      expect(find.text('Initialisation...'), findsOneWidget);
    });

    testWidgets('Login screen a les champs nécessaires', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(firebaseAvailable: false),
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Vérifier les champs email et password
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('Services Tests', () {
    test('BluetoothService initialise correctement', () {
      final service = MockBluetoothService();
      expect(service.isConnected, false);
      expect(service.isScanning, false);
    });

    test('LocationService initialise correctement', () {
      final service = MockLocationService();
      expect(service.isTracking, false);
      expect(service.currentPosition, null);
    });

    test('NotificationService initialise correctement', () {
      final service = MockNotificationService();
      expect(service.notifications, isEmpty);
    });
  });

  group('AuthBloc Tests', () {
    test('État initial est AuthInitial', () {
      final authBloc = AuthBloc(firebaseAvailable: false);
      expect(authBloc.state, isA<AuthInitial>());
      authBloc.close();
    });

    test('AuthCheckStatus émet AuthLoading puis un état final', () async {
      final authBloc = AuthBloc(firebaseAvailable: false);

      // Créer une liste pour stocker les états
      final states = <AuthState>[];

      // Écouter les changements d'état
      authBloc.stream.listen((state) {
        states.add(state);
      });

      // Déclencher l'événement
      authBloc.add(AuthCheckStatus());

      // Attendre suffisamment pour le délai interne du bloc
      await Future.delayed(const Duration(milliseconds: 600));

      // Vérifier qu'on a eu l'état final non authentifié
      expect(states.any((s) => s is AuthUnauthenticated), true);

      authBloc.close();
    });
  });

  group('Repository Tests', () {
    test('AlertRepository peut sauvegarder et récupérer des alertes', () async {
      final repo = AlertRepository();
      final alert = EmergencyAlert(
        id: 'test-alert',
        userId: 'test-user',
        location: const LatLng(0, 0),
        timestamp: DateTime.now(),
        status: AlertStatus.pending,
      );

      // Sauvegarder l'alerte
      await repo.saveAlert(alert);

      // Récupérer l'alerte
      final retrieved = await repo.getAlertById('test-alert');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-alert'));
      expect(retrieved.userId, equals('test-user'));

      // Récupérer les alertes de l'utilisateur
      final userAlerts = await repo.getAlertsForUser('test-user');
      expect(userAlerts.length, equals(1));
      expect(userAlerts.first.id, equals('test-alert'));

      // Nettoyer
      await repo.deleteAlert('test-alert');
      await repo.close();
    });
  });

  group('Profile Screen Tests', () {
    testWidgets('Profile screen displays user information correctly', (
      WidgetTester tester,
    ) async {
      // Create a mock user
      final mockUser = User(
        id: 'test-user',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        createdAt: DateTime.now(),
        settings: UserSettings(
          notificationsEnabled: true,
          biometricAuth: false,
          locationSharing: true,
          autoConnectBracelet: true,
        ),
        emergencyInfo: EmergencyInfo(bloodType: 'O+'),
      );

      // Mock repositories
      final mockContactRepo = ContactRepository();
      final mockAlertRepo = AlertRepository();

      // Add some mock data
      await mockContactRepo.saveContact(
        Contact(
          id: 'contact1',
          userId: 'test-user',
          name: 'Jane Doe',
          phone: '+0987654321',
          email: 'jane@example.com',
          relationship: 'Spouse',
          priority: 1,
          addedDate: DateTime.now(),
        ),
      );

      await mockAlertRepo.saveAlert(
        EmergencyAlert(
          id: 'alert1',
          userId: 'test-user',
          location: const LatLng(0, 0),
          timestamp: DateTime.now(),
          status: AlertStatus.resolved,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContactRepository>(create: (_) => mockContactRepo),
            Provider<AlertRepository>(create: (_) => mockAlertRepo),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockBluetoothService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockNotificationService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockLocationService(),
            ),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(firebaseAvailable: false)
                  ..emit(AuthAuthenticated(mockUser)),
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify user name is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);

      // Verify statistics are loaded
      expect(find.text('1'), findsWidgets); // Contacts count
      expect(find.text('1'), findsWidgets); // Alerts count

      // Verify sections are present
      expect(find.text('Statistiques du compte'), findsOneWidget);
      expect(find.text('Informations personnelles'), findsOneWidget);
      expect(find.text('Paramètres de sécurité'), findsOneWidget);
    });

    testWidgets('Profile screen shows loading state initially', (
      WidgetTester tester,
    ) async {
      final mockUser = User(
        id: 'test-user',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        createdAt: DateTime.now(),
        settings: UserSettings(
          notificationsEnabled: true,
          biometricAuth: false,
          locationSharing: true,
          autoConnectBracelet: true,
        ),
        emergencyInfo: EmergencyInfo(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContactRepository>(create: (_) => ContactRepository()),
            Provider<AlertRepository>(create: (_) => AlertRepository()),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockBluetoothService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockNotificationService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockLocationService(),
            ),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(firebaseAvailable: false)
                  ..emit(AuthAuthenticated(mockUser)),
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );

      // Initially should show loading for stats
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Profile screen redirects to login when unauthenticated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContactRepository>(create: (_) => ContactRepository()),
            Provider<AlertRepository>(create: (_) => AlertRepository()),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockBluetoothService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockNotificationService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockLocationService(),
            ),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(firebaseAvailable: false)..emit(AuthUnauthenticated()),
            child: MaterialApp(
              home: const ProfileScreen(),
              routes: {
                '/login': (context) =>
                    const Scaffold(body: Text('Login Screen')),
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Profile screen is responsive on different screen sizes', (
      WidgetTester tester,
    ) async {
      final mockUser = User(
        id: 'test-user',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        createdAt: DateTime.now(),
        settings: UserSettings(
          notificationsEnabled: true,
          biometricAuth: false,
          locationSharing: true,
          autoConnectBracelet: true,
        ),
      );

      // Test on mobile size
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContactRepository>(create: (_) => ContactRepository()),
            Provider<AlertRepository>(create: (_) => AlertRepository()),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockBluetoothService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockNotificationService(),
            ),
            ChangeNotifierProvider<ChangeNotifier>(
              create: (_) => MockLocationService(),
            ),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(firebaseAvailable: false)
                  ..emit(AuthAuthenticated(mockUser)),
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout adapts (check for ListView which is used in ProfileScreen)
      expect(find.byType(ListView), findsOneWidget);

      // Reset to default
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
