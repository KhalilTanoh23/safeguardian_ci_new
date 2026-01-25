import 'package:flutter/material.dart';

/// Mixin pour ajouter facilement des propriétés responsive aux widgets
mixin ResponsiveMixin {
  /// Obtient la largeur de l'écran
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Obtient la hauteur de l'écran
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Obtient l'orientation
  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  /// Vérifie si c'est un petit téléphone
  static bool isSmallPhone(BuildContext context) =>
      getScreenWidth(context) < 360;

  /// Vérifie si c'est un téléphone
  static bool isPhone(BuildContext context) => getScreenWidth(context) < 600;

  /// Vérifie si c'est une tablette
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 1200;
  }

  /// Vérifie si c'est un ordinateur
  static bool isDesktop(BuildContext context) =>
      getScreenWidth(context) >= 1200;

  /// Vérifie si l'orientation est portrait
  static bool isPortrait(BuildContext context) =>
      getOrientation(context) == Orientation.portrait;

  /// Vérifie si l'orientation est paysage
  static bool isLandscape(BuildContext context) =>
      getOrientation(context) == Orientation.landscape;

  /// Obtient un pourcentage de la largeur de l'écran
  static double widthPercent(BuildContext context, double percent) =>
      getScreenWidth(context) * (percent / 100);

  /// Obtient un pourcentage de la hauteur de l'écran
  static double heightPercent(BuildContext context, double percent) =>
      getScreenHeight(context) * (percent / 100);

  /// Obtient la taille d'une propriété en fonction du device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = getScreenWidth(context);
    if (width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Obtient le nombre de colonnes pour un GridView
  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  /// Obtient le padding adaptatif
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return const EdgeInsets.all(12);
    if (width < 900) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  /// Obtient la hauteur d'une AppBar adaptative
  static double getAppBarHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return 56;
    if (width < 900) return 64;
    return 72;
  }

  /// Obtient la hauteur d'un bouton adaptatif
  static double getButtonHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return 48;
    if (width < 900) return 52;
    return 56;
  }

  /// Obtient la taille d'une icône adaptative
  static double getIconSize(BuildContext context, {String size = 'medium'}) {
    final width = getScreenWidth(context);
    switch (size) {
      case 'small':
        return width < 600 ? 20 : (width < 900 ? 24 : 28);
      case 'large':
        return width < 600 ? 32 : (width < 900 ? 36 : 44);
      case 'medium':
      default:
        return width < 600 ? 24 : (width < 900 ? 28 : 32);
    }
  }

  /// Obtient la taille de police adaptative
  static double getFontSize(BuildContext context, {String size = 'body'}) {
    final width = getScreenWidth(context);
    switch (size) {
      case 'tiny':
        return width < 600 ? 10 : 11;
      case 'small':
        return width < 600 ? 12 : (width < 900 ? 13 : 14);
      case 'body':
        return width < 600 ? 14 : (width < 900 ? 15 : 16);
      case 'heading':
        return width < 600 ? 18 : (width < 900 ? 20 : 24);
      case 'title':
        return width < 600 ? 22 : (width < 900 ? 26 : 32);
      default:
        return 16;
    }
  }

  /// Obtient la largeur maximale pour le contenu
  static double getMaxContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return width * 0.9;
    if (width < 900) return width * 0.8;
    if (width < 1200) return 900;
    return 1000;
  }

  /// Obtient le nombre d'items par ligne dans un wrapping layout
  static int getItemsPerRow(BuildContext context, double itemWidth) {
    final screenWidth = getScreenWidth(context);
    final padding = getResponsivePadding(context);
    final availableWidth = screenWidth - (padding.left + padding.right);
    return (availableWidth / itemWidth).floor();
  }
}
