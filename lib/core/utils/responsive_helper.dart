import 'package:flutter/material.dart';

/// Classe utilitaire pour gérer la responsivité sur tous les appareils
class ResponsiveHelper {
  final BuildContext context;
  late MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;

  ResponsiveHelper(this.context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
  }

  // ===== Getters de base =====
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  double get devicePixelRatio => _mediaQueryData.devicePixelRatio;
  Orientation get orientation => _mediaQueryData.orientation;

  // ===== Détection des catégories d'appareils =====
  bool get isMobile => _screenWidth < 600;
  bool get isTablet => _screenWidth >= 600 && _screenWidth < 1200;
  bool get isDesktop => _screenWidth >= 1200;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // ===== Tailles d'écran spécifiques =====
  bool get isSmallPhone => _screenWidth < 360; // Très petit téléphone
  bool get isPhone => _screenWidth < 600; // Téléphone standard
  bool get isLargePhone =>
      _screenWidth >= 480 && _screenWidth < 600; // Grand téléphone
  bool get isSmallTablet => _screenWidth >= 600 && _screenWidth < 800;
  bool get isLargeTablet => _screenWidth >= 800 && _screenWidth < 1200;

  // ===== Valeurs de padding/margin adaptatives =====
  double get paddingXSmall => _screenWidth * 0.02; // 2% de la largeur
  double get paddingSmall => _screenWidth * 0.04; // 4%
  double get paddingMedium => _screenWidth * 0.05; // 5%
  double get paddingLarge => _screenWidth * 0.06; // 6%
  double get paddingXLarge => _screenWidth * 0.08; // 8%

  // ===== Tailles de police adaptatives =====
  double get fontSizeSmall => isMobile ? 12 : (isTablet ? 14 : 16);
  double get fontSizeNormal => isMobile ? 14 : (isTablet ? 16 : 18);
  double get fontSizeMedium => isMobile ? 16 : (isTablet ? 18 : 20);
  double get fontSizeLarge => isMobile ? 18 : (isTablet ? 20 : 24);
  double get fontSizeXLarge => isMobile ? 22 : (isTablet ? 24 : 32);
  double get fontSizeTitle => isMobile ? 24 : (isTablet ? 28 : 36);

  // ===== Hauteurs adaptatives =====
  double get buttonHeight => isMobile ? 48 : (isTablet ? 54 : 60);
  double get appBarHeight => isMobile ? 56 : (isTablet ? 64 : 72);
  double get bottomNavHeight => isMobile ? 56 : (isTablet ? 64 : 70);

  // ===== Nombres de colonnes pour GridView =====
  int get gridColumns {
    if (isSmallPhone) return 2;
    if (isPhone) return 2;
    if (isSmallTablet) return 3;
    if (isLargeTablet) return 4;
    return 5; // Desktop
  }

  // ===== Nombres de colonnes pour listes =====
  int get listColumns {
    if (isMobile) return 1;
    if (isSmallTablet) return 2;
    if (isLargeTablet) return 3;
    return 4; // Desktop
  }

  // ===== Taille des icônes =====
  double get iconSizeSmall => isMobile ? 20 : (isTablet ? 24 : 28);
  double get iconSizeMedium => isMobile ? 24 : (isTablet ? 28 : 32);
  double get iconSizeLarge => isMobile ? 28 : (isTablet ? 32 : 40);
  double get iconSizeXLarge => isMobile ? 36 : (isTablet ? 44 : 56);

  // ===== Largeur maximale pour les contenu =====
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isLargeTablet) return 900;
    return double.infinity;
  }

  // ===== Hauteur d'espaceurs =====
  double get spacerSmall => 8;
  double get spacerMedium => 16;
  double get spacerLarge => 24;
  double get spacerXLarge => 32;

  // ===== Border radius adaptatif =====
  double get radiusSmall => isMobile ? 8 : 12;
  double get radiusMedium => isMobile ? 12 : 16;
  double get radiusLarge => isMobile ? 16 : 24;
}

/// Extension pour accès facile à ResponsiveHelper
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
