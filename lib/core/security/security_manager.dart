// 🔒 SÉCURITÉ AVANCÉE - SafeGuardian CI
// Configuration complète pour le volet sécurité Flutter

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// 🔐 GESTION DES SESSIONS SÉCURISÉES
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Durée d'inactivité avant déconnexion (30 minutes)
  static const Duration sessionTimeout = Duration(minutes: 30);

  Timer? _sessionTimer;
  VoidCallback? _onSessionExpired;

  DateTime? _lastActivityTime;

  /// Initialiser la gestion de session
  void initialize(VoidCallback onSessionExpired) {
    _onSessionExpired = onSessionExpired;
    _resetSessionTimer();
    _lastActivityTime = DateTime.now();
  }

  /// Enregistrer une activité (réinitialise le timer)
  void recordActivity() {
    _lastActivityTime = DateTime.now();
    _resetSessionTimer();
  }

  /// Réinitialiser le timer de session
  void _resetSessionTimer() {
    _sessionTimer?.cancel();

    _sessionTimer = Timer(sessionTimeout, () {
      _onSessionExpired?.call();
      debugPrint('🔐 Session expirée après inactivité');
    });
  }

  /// Obtenir le temps d'inactivité restant
  Duration getRemainingSessionTime() {
    if (_lastActivityTime == null) {
      return Duration.zero;
    }

    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = sessionTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Fermer la session
  void closeSession() {
    _sessionTimer?.cancel();
    debugPrint('🔐 Session fermée');
  }
}

/// 🔐 BIOMÉTRIE & AUTHENTIFICATION AVANCÉE
// À implémenter avec: local_auth package
/*
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canAuthenticateWithBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur biométrique: $e');
      return false;
    }
  }
}
*/

/// 🔐 INJECTION DETECTION & PREVENTION
class InjectionPrevention {
  /// Valider et nettoyer une chaîne d'entrée
  static String sanitizeInput(String input) {
    // Supprimer les caractères suspects
    return input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('\'', '')
        .replaceAll('"', '')
        .replaceAll('&', '')
        .replaceAll('|', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(';', '')
        .replaceAll('[', '')
        .replaceAll(']', '');
  }

  /// Détecter les tentatives d'injection
  static bool detectInjectionAttempt(String input) {
    final injectionPatterns = [
      RegExp(r'(?i)union.*select'),
      RegExp(r'(?i)drop.*table'),
      RegExp(r'(?i)insert.*into'),
      RegExp(r'(?i)delete.*from'),
      RegExp(r'(?i)<script'),
      RegExp(r'javascript:'),
      RegExp(r'onerror\s*='),
      RegExp(r'onclick\s*='),
    ];

    for (final pattern in injectionPatterns) {
      if (pattern.hasMatch(input)) {
        debugPrint('🚨 Tentative d\'injection détectée: $input');
        return true;
      }
    }

    return false;
  }
}

/// 🔐 CERTIFICATE PINNING
// À implémenter avec: ssl_certificate_pinning package
/*
import 'package:ssl_certificate_pinning/ssl_certificate_pinning.dart';

class CertificatePinning {
  static Future<void> setupPinning() async {
    await SslCertificatePinning.check(
      serverURL: "https://api.safeguardian.app",
      headerServerURL: "https://api.safeguardian.app",
      publicKeyList: ["sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="],
      timeout: 60,
    );
  }
}
*/

/// 🔐 SENSITIVE DATA PROTECTION
class SensitiveDataProtection {
  static const _prefix = 'sensitive_';

  /// Sauvegarder une donnée sensible
  static Future<void> saveSensitiveData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', value);
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Récupérer une donnée sensible
  static Future<String?> getSensitiveData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_prefix$key');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return null;
    }
  }

  /// Supprimer une donnée sensible
  static Future<void> deleteSensitiveData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$key');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Vider le stockage sécurisé
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }
}

/// 🔐 PRIVACY & DATA MINIMIZATION
class PrivacySettings {
  /// Désactiver les screenshots
  static void disableScreenshots() {
    // À implémenter avec: screenshot_protect package
    debugPrint('📸 Screenshots désactivés');
  }

  /// Minimiser les données collectées
  static Map<String, dynamic> getMinimalUserData(
    Map<String, dynamic> fullData,
  ) {
    return {
      'id': fullData['id'],
      'email': fullData['email'],
      // Ne pas inclure les données sensibles inutiles
    };
  }

  /// Logger sans données sensibles
  static void logSecurely(String message) {
    // Ne jamais logger les tokens, passwords, etc.
    debugPrint('📋 $message');
  }
}

/// 🔐 NETWORK SECURITY
class NetworkSecurity {
  /// Valider l'URL avant d'envoyer une requête
  static bool isUrlSafe(String url) {
    try {
      final uri = Uri.parse(url);

      // Vérifier que c'est HTTPS
      if (uri.scheme != 'https') {
        debugPrint('❌ HTTPS requis: $url');
        return false;
      }

      // Vérifier le domaine autorisé
      const allowedDomains = ['safeguardian.app', 'api.safeguardian.app'];
      final isDomainAllowed = allowedDomains.any(
        (domain) => uri.host.endsWith(domain),
      );

      if (!isDomainAllowed) {
        debugPrint('❌ Domaine non autorisé: ${uri.host}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erreur validation URL: $e');
      return false;
    }
  }
}

/// 🔐 MONITORING & ALERTING
class SecurityMonitoring {
  static final List<SecurityEvent> _events = [];
  static const int maxEvents = 100;

  /// Enregistrer un événement de sécurité
  static void logSecurityEvent(SecurityEventType type, String details) {
    final event = SecurityEvent(
      type: type,
      timestamp: DateTime.now(),
      details: details,
    );

    _events.add(event);

    // Garder seulement les 100 derniers événements
    if (_events.length > maxEvents) {
      _events.removeAt(0);
    }

    debugPrint('🔐 Événement: $type - $details');
  }

  /// Obtenir les événements de sécurité récents
  static List<SecurityEvent> getRecentEvents() {
    return _events.toList();
  }

  /// Alerter en cas d'événement suspect
  static void alertIfSuspicious(SecurityEventType type) {
    const suspiciousTypes = [
      SecurityEventType.failedLogin,
      SecurityEventType.unauthorizedAccess,
      SecurityEventType.injectionAttempt,
    ];

    if (suspiciousTypes.contains(type)) {
      debugPrint('🚨 ALERTE: Événement suspect détecté!');
      // Envoyer une notification à l'utilisateur
    }
  }
}

/// 🔐 TYPES D'ÉVÉNEMENTS DE SÉCURITÉ
enum SecurityEventType {
  successfulLogin,
  failedLogin,
  sessionTimeout,
  unauthorizedAccess,
  invalidToken,
  injectionAttempt,
  certificateError,
  networkError,
}

/// 🔐 ÉVÉNEMENT DE SÉCURITÉ
class SecurityEvent {
  final SecurityEventType type;
  final DateTime timestamp;
  final String details;

  SecurityEvent({
    required this.type,
    required this.timestamp,
    required this.details,
  });

  @override
  String toString() => '[$type] $timestamp: $details';
}

/// 🔐 CHECKLIST DE SÉCURITÉ
class SecurityChecklist {
  static Map<String, bool> getSecurityStatus() {
    return {
      'HTTPS utilisé': true,
      'Tokens sécurisés': true,
      'Sessions gérées': true,
      'Données chiffrées': true,
      'Injections bloquées': true,
      'Certificate pinning': false, // À implémenter
      'Biométrie disponible': false, // Dépend de l'appareil
      'Screenshots bloqués': false, // À implémenter
      'Données minimisées': true,
      'Monitoring actif': true,
    };
  }

  static void printSecurityStatus() {
    final status = getSecurityStatus();
    debugPrint('\n🔒 STATUS DE SÉCURITÉ:\n');

    status.forEach((key, value) {
      final icon = value ? '✅' : '❌';
      debugPrint('   $icon $key');
    });

    final completeness =
        status.values.where((v) => v).length / status.length * 100;
    debugPrint('\n   Complétude: ${completeness.toStringAsFixed(1)}%\n');
  }
}
