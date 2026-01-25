/// Configuration centralisée des breakpoints et valeurs responsives
import 'package:flutter/material.dart';

class ResponsiveConfig {
  // ===== Breakpoints =====
  static const double smallPhoneBreakpoint = 360;
  static const double phoneBreakpoint = 600;
  static const double smallTabletBreakpoint = 800;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1920;

  // ===== Padding =====
  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 12;
  static const double paddingLarge = 16;
  static const double paddingXLarge = 24;
  static const double paddingXXLarge = 32;

  // ===== Margin =====
  static const double marginXSmall = 4;
  static const double marginSmall = 8;
  static const double marginMedium = 12;
  static const double marginLarge = 16;
  static const double marginXLarge = 24;

  // ===== Border Radius =====
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;

  // ===== Font Sizes =====
  static const double fontSizeTiny = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeNormal = 14;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 24;
  static const double fontSizeTitle = 32;

  // ===== Icon Sizes =====
  static const double iconSizeSmall = 18;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;

  // ===== Heights =====
  static const double appBarHeightMobile = 56;
  static const double appBarHeightTablet = 64;
  static const double appBarHeightDesktop = 72;

  static const double buttonHeightMobile = 44;
  static const double buttonHeightTablet = 48;
  static const double buttonHeightDesktop = 52;

  static const double bottomNavHeightMobile = 56;
  static const double bottomNavHeightTablet = 64;

  // ===== Grid =====
  static const int gridColumnsPhoneSmall = 1;
  static const int gridColumnsPhone = 2;
  static const int gridColumnsTabletSmall = 3;
  static const int gridColumnsTablet = 4;
  static const int gridColumnsDesktop = 5;

  // ===== Durations =====
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ===== Curves =====
  static const animationCurve = Cubic(0.4, 0.0, 0.2, 1.0); // Material curve

  // ===== Max Widths =====
  static const double maxWidthPhone = 500;
  static const double maxWidthTablet = 900;
  static const double maxWidthDesktop = 1200;
  static const double maxWidthLargeDesktop = 1400;

  // ===== Shadows =====
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // ===== Aspect Ratios =====
  static const double aspectRatioCard = 1.2;
  static const double aspectRatioImage = 16 / 9;
  static const double aspectRatioBanner = 4 / 1;
  static const double aspectRatioProfile = 1 / 1;
}
