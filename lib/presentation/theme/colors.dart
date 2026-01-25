// lib/presentation/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales SILENTOPS
  static const Color primary = Color(0xFF1A237E); // Bleu foncé sérieux
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);

  static const Color secondary = Color(0xFF00B0FF); // Bleu vif pour alertes
  static const Color secondaryLight = Color(0xFF69E2FF);
  static const Color secondaryDark = Color(0xFF0081CB);

  static const Color accent = Color(0xFFE91E63); // Rose pour urgences
  static const Color accentLight = Color(0xFFFF6090);
  static const Color accentDark = Color(0xFFB0003A);

  // Couleurs de sécurité
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFFF6659);
  static const Color emergencyDark = Color(0xFF9A0007);

  static const Color warningYellow = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFD149);
  static const Color warningDark = Color(0xFFC67100);

  static const Color safeGreen = Color(0xFF388E3C);
  static const Color safeLight = Color(0xFF6ABF69);
  static const Color safeDark = Color(0xFF00600F);

  // Couleurs neutres
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF6D6D6D);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Couleurs de statut
  static const Color success = Color(0xFF4CAF50);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color error = Color(0xFFF44336);
  static const Color errorRed = Color(0xFFF44336);

  // Couleurs de bordure
  static const Color borderDark = Color(0xFF424242);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF388E3C), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleurs spécifiques à l'application
  static const Color braceletConnected = Color(0xFF4CAF50);
  static const Color braceletDisconnected = Color(0xFFF44336);
  static const Color batteryFull = Color(0xFF4CAF50);
  static const Color batteryMedium = Color(0xFFFF9800);
  static const Color batteryLow = Color(0xFFF44336);

  // Couleurs futuristes pour le design moderne
  static const Color futuristicDarkBlue = Color(0xFF0F0F23);
  static const Color futuristicDarkPurple = Color(0xFF1A0B2E);
  static const Color futuristicDeepBlue = Color(0xFF0A0A1E);
  static const Color futuristicAccentBlue = Color(0xFF00D4FF);
  static const Color futuristicAccentPurple = Color(0xFF9D4EDD);
  static const Color futuristicAccentNeon = Color(0xFF00FF88);
  static const Color futuristicAccentPink = Color(0xFFFF0080);
  static const Color futuristicGlassOverlay = Color(0x80FFFFFF);
  static const Color futuristicShadow = Color(0x40000000);

  // Gradients futuristes
  static const LinearGradient futuristicBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0F23), Color(0xFF1A0B2E), Color(0xFF0A0A1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient futuristicCardGradient = LinearGradient(
    colors: [Color(0x20FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient futuristicHeaderGradient = LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF00D4FF), Color(0xFFFF0080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient futuristicAccentGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF9D4EDD)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Couleurs des catégories
  static const Map<String, Color> categoryColors = {
    'electronics': Color(0xFF2196F3),
    'jewelry': Color(0xFFFF9800),
    'documents': Color(0xFF4CAF50),
    'keys': Color(0xFF9C27B0),
    'wallet': Color(0xFF795548),
    'other': Color(0xFF607D8B),
  };
}
