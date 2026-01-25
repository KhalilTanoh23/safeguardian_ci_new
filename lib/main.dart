import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/constants/routes.dart';
import 'core/services/bluetooth_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'data/repositories/alert_repository.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/widgets/auth_wrapper.dart';

// Importez vos adapters Hive ici
// import 'data/models/alert.dart'; // Pour EmergencyAlertAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 Démarrage de SafeGuardian CI');

  bool firebaseInitialized = false;

  try {
    // 1. Initialiser Firebase
    debugPrint('🔥 Initialisation Firebase...');
    final options = DefaultFirebaseOptions.currentPlatform;
    // Vérifier si c'est une configuration dummy
    if (options.apiKey.startsWith('AIzaSyDummy')) {
      debugPrint('⚠️ Configuration Firebase dummy détectée - mode hors ligne');
      firebaseInitialized = false;
    } else {
      await Firebase.initializeApp(options: options);
      firebaseInitialized = true;
      debugPrint('✅ Firebase initialisé avec succès');
    }
  } catch (e) {
    debugPrint('❌ Erreur Firebase: $e');
    debugPrint('🔄 L\'application démarrera en mode hors ligne');
  }

  try {
    // 2. Initialiser Hive
    debugPrint('📦 Initialisation Hive...');
    await Hive.initFlutter();
    debugPrint('✅ Hive initialisé avec succès');

    // 3. Enregistrer les adapters Hive
    // Décommentez et ajoutez vos adapters personnalisés
    // if (!Hive.isAdapterRegistered(0)) {
    //   Hive.registerAdapter(EmergencyAlertAdapter());
    //   debugPrint('✅ EmergencyAlertAdapter enregistré');
    // }

    // 4. Lancer l'application
    debugPrint('🎯 Lancement de l\'application...');
    runApp(SafeGuardianApp(firebaseAvailable: firebaseInitialized));
    debugPrint('✅ Application lancée');
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur d\'initialisation: $e');
    debugPrint('📄 Stack trace: $stackTrace');

    // Afficher un écran d'erreur
    runApp(ErrorApp(error: e.toString()));
  }
}

class SafeGuardianApp extends StatelessWidget {
  final bool firebaseAvailable;

  const SafeGuardianApp({super.key, required this.firebaseAvailable});

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🏗️ Construction de SafeGuardianApp (Firebase: $firebaseAvailable)',
    );
    return MultiProvider(
      providers: [
        // Repository providers
        Provider<AlertRepository>(
          create: (_) => AlertRepository(),
          dispose: (_, repo) => repo.close(),
        ),

        // Service providers avec ChangeNotifier
        ChangeNotifierProvider<BluetoothService>(
          create: (_) => BluetoothService(),
          lazy: true, // Initialise seulement quand nécessaire
        ),

        ChangeNotifierProvider<NotificationService>(
          create: (_) => NotificationService(),
          lazy: true, // Initialise seulement quand nécessaire
        ),

        ChangeNotifierProvider<LocationService>(
          create: (_) => LocationService(),
          lazy: true, // Initialise seulement quand nécessaire
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(firebaseAvailable: firebaseAvailable)
                  ..add(AuthCheckStatus()),
          ),

          // Ajoutez d'autres blocs si nécessaire
          // BlocProvider<AlertBloc>(
          //   create: (context) => AlertBloc(
          //     alertRepository: context.read<AlertRepository>(),
          //   ),
          // ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeGuardian CI',
          // Configuration responsive
          builder: (context, child) {
            // Désactiver la taille de texte du système pour une cohérence responsive
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: false,
            ),
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              dense: false,
            ),
          ),
          // Dark theme
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: false,
            ),
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              dense: false,
            ),
          ),
          themeMode: ThemeMode.system,
          // Let the AuthWrapper decide which screen to show first.
          home: const AuthWrapper(),
          navigatorKey: NotificationService.navigatorKey,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}

/// Widget d'erreur en cas de problème d'initialisation
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: SelectableText(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vérifications à effectuer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ErrorCheckItem(
                    icon: Icons.check_circle_outline,
                    text: 'Firebase configuré (flutterfire configure)',
                  ),
                  const _ErrorCheckItem(
                    icon: Icons.check_circle_outline,
                    text: 'google-services.json présent (Android)',
                  ),
                  const _ErrorCheckItem(
                    icon: Icons.check_circle_outline,
                    text: 'GoogleService-Info.plist présent (iOS)',
                  ),
                  const _ErrorCheckItem(
                    icon: Icons.check_circle_outline,
                    text: 'flutter pub get exécuté',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Note: Le redémarrage nécessite un hot restart complet
                      debugPrint(
                        'Pour réessayer, faites un hot restart (Ctrl+Shift+F5)',
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer (Hot Restart)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCheckItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ErrorCheckItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
