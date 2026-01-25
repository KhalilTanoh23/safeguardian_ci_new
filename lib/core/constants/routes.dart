import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Screens
import 'package:safeguardian_ci_new/presentation/screens/main/splash_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/auth/login_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/auth/register_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/emergency/emergency_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/emergency/alert_map_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/emergency/alert_history_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/contacts/contacts_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/contacts/add_contact_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/items/items_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/items/add_item_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/items/lost_found_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/documents/documents_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/documents/add_document_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/device/pair_device_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/device/device_settings_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/community/community_alerts_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/community/help_center_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/admin/admin_dashboard.dart';
import 'package:safeguardian_ci_new/presentation/screens/settings/settings_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/profile/profile_screen.dart';
import 'package:safeguardian_ci_new/presentation/widgets/auth_wrapper.dart';

/// Gestion centralisée des routes de l'application
class AppRoutes {
  // Routes principales (French localization)
  static const String splash = '/';
  static const String authWrapper = '/enveloppe-auth';
  static const String onboarding = '/demarrage';
  static const String login = '/connexion';
  static const String register = '/inscription';
  static const String dashboard = '/tableau-de-bord';
  static const String emergency = '/urgence';
  static const String alertMap = '/carte-alerte';
  static const String alertHistory = '/historique-alerte';
  static const String contacts = '/contacts';
  static const String addContact = '/ajouter-contact';
  static const String items = '/objets';
  static const String addItem = '/ajouter-objet';
  static const String lostFound = '/perdu-trouve';
  static const String documents = '/documents';
  static const String addDocument = '/ajouter-document';
  static const String pairDevice = '/appairer-appareil';
  static const String deviceSettings = '/parametres-appareil';
  static const String communityAlerts = '/alertes-communaute';
  static const String helpCenter = '/centre-aide';
  static const String adminDashboard = '/tableau-de-bord-admin';
  static const String settings = '/parametres';
  static const String profile = '/profil';

  /// Générateur de routes de navigation
  /// Mappe les chemins (routes) aux écrans correspondants
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name;
    final args = routeSettings.arguments;

    try {
      // Utilisation de if-else au lieu de switch pour éviter les erreurs de constantes
      if (name == splash) {
        return _buildRoute(const SplashScreen(), routeSettings);
      } else if (name == authWrapper) {
        return _buildRoute(const AuthWrapper(), routeSettings);
      } else if (name == onboarding) {
        return _buildRoute(const OnboardingScreen(), routeSettings);
      } else if (name == login) {
        return _buildRoute(const LoginScreen(), routeSettings);
      } else if (name == register) {
        return _buildRoute(const RegisterScreen(), routeSettings);
      } else if (name == dashboard) {
        return _buildRoute(const DashboardScreen(), routeSettings);
      } else if (name == emergency) {
        final emergencyArgs = _parseArgs<Map<String, dynamic>>(args) ?? {};
        return _buildRoute(
          EmergencyScreen(alertData: emergencyArgs),
          routeSettings,
        );
      } else if (name == alertMap) {
        final alertMapArgs = _parseArgs<Map<String, dynamic>>(args) ?? {};
        final alertLocation =
            alertMapArgs['alertLocation'] as LatLng? ?? LatLng(0, 0);
        final alertId = alertMapArgs['alertId'] as String? ?? '';
        return _buildRoute(
          AlertMapScreen(alertLocation: alertLocation, alertId: alertId),
          routeSettings,
        );
      } else if (name == alertHistory) {
        return _buildRoute(const AlertHistoryScreen(), routeSettings);
      } else if (name == contacts) {
        return _buildRoute(const EmergencyContactsScreen(), routeSettings);
      } else if (name == addContact) {
        return _buildRoute(const AddEmergencyContactScreen(), routeSettings);
      } else if (name == items) {
        return _buildRoute(const ItemsScreen(), routeSettings);
      } else if (name == addItem) {
        return _buildRoute(const AddItemScreen(), routeSettings);
      } else if (name == lostFound) {
        return _buildRoute(const LostFoundScreen(), routeSettings);
      } else if (name == documents) {
        return _buildRoute(const DocumentsScreen(), routeSettings);
      } else if (name == addDocument) {
        return _buildRoute(const AddDocumentScreen(), routeSettings);
      } else if (name == pairDevice) {
        return _buildRoute(const PairDeviceScreen(), routeSettings);
      } else if (name == deviceSettings) {
        return _buildRoute(const DeviceSettingsScreen(), routeSettings);
      } else if (name == communityAlerts) {
        return _buildRoute(const CommunityAlertsScreen(), routeSettings);
      } else if (name == helpCenter) {
        return _buildRoute(const HelpCenterScreen(), routeSettings);
      } else if (name == adminDashboard) {
        return _buildRoute(const AdminDashboardScreen(), routeSettings);
      } else if (name == settings) {
        return _buildRoute(const SettingsScreen(), routeSettings);
      } else if (name == profile) {
        return _buildRoute(const ProfileScreen(), routeSettings);
      } else {
        // Route 404
        return _buildRoute(
          _UndefinedRouteScreen(routeName: routeSettings.name),
          routeSettings,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur génération route ${routeSettings.name}: $e');
      debugPrint('Stack trace: $stackTrace');

      return _buildRoute(
        _ErrorRouteScreen(routeName: routeSettings.name, error: e.toString()),
        routeSettings,
      );
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(
    Widget screen,
    RouteSettings routeSettings,
  ) {
    return MaterialPageRoute<T>(
      builder: (_) => screen,
      settings: routeSettings,
    );
  }

  static T? _parseArgs<T>(dynamic args) {
    if (args is T) return args;
    return null;
  }

  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}

class _UndefinedRouteScreen extends StatelessWidget {
  final String? routeName;
  const _UndefinedRouteScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur'), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 100, color: Colors.red.shade300),
              const SizedBox(height: 24),
              const Text(
                'Route inconnue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (routeName != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    routeName!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.splash,
                  (route) => false,
                ),
                icon: const Icon(Icons.home),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRouteScreen extends StatelessWidget {
  final String? routeName;
  final String error;
  const _ErrorRouteScreen({this.routeName, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur'), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'Erreur de navigation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (routeName != null) ...[
                const SizedBox(height: 16),
                Text('Route: $routeName'),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: SelectableText(
                  error,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.splash,
                  (route) => false,
                ),
                icon: const Icon(Icons.home),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
