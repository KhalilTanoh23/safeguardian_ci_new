import 'package:flutter/material.dart';

/// Thème responsive pour l'application
class ResponsiveTheme {
  // Définir les breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Padding et Margin responsives
  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const EdgeInsets.all(12);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  static EdgeInsets getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 16, horizontal: 20);
    }
  }

  // Card responsive
  static EdgeInsets getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const EdgeInsets.all(12);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  // AppBar responsive
  static double getAppBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 56;
    if (width < tabletBreakpoint) return 64;
    return 72;
  }

  // Font sizes responsives
  static TextStyle getHeadline1(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < mobileBreakpoint
        ? 24
        : (width < tabletBreakpoint ? 28 : 32);
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.bold,
      color: const Color(0xFF1E3A8A),
    );
  }

  static TextStyle getHeadline2(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < mobileBreakpoint
        ? 20
        : (width < tabletBreakpoint ? 24 : 28);
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.bold,
      color: const Color(0xFF1E3A8A),
    );
  }

  static TextStyle getHeadline3(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < mobileBreakpoint
        ? 18
        : (width < tabletBreakpoint ? 20 : 24);
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF374151),
    );
  }

  static TextStyle getBodyText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < mobileBreakpoint
        ? 14
        : (width < tabletBreakpoint ? 15 : 16);
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.normal,
      color: const Color(0xFF6B7280),
    );
  }

  static TextStyle getSmallText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < mobileBreakpoint
        ? 12
        : (width < tabletBreakpoint ? 13 : 14);
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.normal,
      color: const Color(0xFF9CA3AF),
    );
  }

  // Button sizes
  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 48;
    if (width < tabletBreakpoint) return 52;
    return 56;
  }

  static double getButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width * 0.8;
    if (width < tabletBreakpoint) return width * 0.6;
    return 200;
  }

  // Icon sizes
  static double getIconSize(BuildContext context, {required String size}) {
    final width = MediaQuery.of(context).size.width;
    switch (size) {
      case 'small':
        return width < mobileBreakpoint
            ? 20
            : (width < tabletBreakpoint ? 24 : 28);
      case 'medium':
        return width < mobileBreakpoint
            ? 28
            : (width < tabletBreakpoint ? 32 : 36);
      case 'large':
        return width < mobileBreakpoint
            ? 40
            : (width < tabletBreakpoint ? 48 : 56);
      default:
        return 24;
    }
  }

  // Grid columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 2;
    if (width < tabletBreakpoint) return 3;
    return 4;
  }

  // Card width
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width * 0.9;
    if (width < tabletBreakpoint) return (width - 48) / 2;
    return (width - 80) / 3;
  }

  // Dialog width
  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width * 0.9;
    if (width < tabletBreakpoint) return width * 0.7;
    return 500;
  }

  // Spacing values
  static double getSpacing(BuildContext context, {required String size}) {
    final width = MediaQuery.of(context).size.width;
    switch (size) {
      case 'xs':
        return 4;
      case 'sm':
        return 8;
      case 'md':
        return width < mobileBreakpoint ? 12 : 16;
      case 'lg':
        return width < mobileBreakpoint ? 16 : 24;
      case 'xl':
        return width < mobileBreakpoint ? 20 : 32;
      default:
        return 0;
    }
  }

  // Border radius responsive
  static double getBorderRadius(BuildContext context, {required String size}) {
    final width = MediaQuery.of(context).size.width;
    switch (size) {
      case 'small':
        return 8;
      case 'medium':
        return width < mobileBreakpoint ? 12 : 16;
      case 'large':
        return width < mobileBreakpoint ? 16 : 24;
      default:
        return 12;
    }
  }
}
