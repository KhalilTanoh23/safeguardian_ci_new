import 'package:flutter/material.dart';

/// Widget qui fournit un layout responsive automatique
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Widget pour adapter la largeur du contenu
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = maxWidth ?? (screenWidth > 1200 ? 1200 : screenWidth);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// GridView responsive
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int Function(BuildContext) crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount(context),
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Padding responsive
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets Function(BuildContext) padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding(context), child: child);
  }
}

/// Text responsive
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double Function(BuildContext)? sizeCalculator;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.sizeCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = baseStyle?.fontSize ?? 14;

    // Adapter la taille de police en fonction de la largeur de l'écran
    double scaleFactor;
    if (screenWidth < 360) {
      scaleFactor = 0.85;
    } else if (screenWidth < 600) {
      scaleFactor = 0.95;
    } else if (screenWidth < 900) {
      scaleFactor = 1.0;
    } else {
      scaleFactor = 1.1;
    }

    final fontSize =
        sizeCalculator?.call(context) ?? (baseFontSize * scaleFactor);

    return Text(
      text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Widget pour adapter les dimensions des images
class ResponsiveImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double Function(double)? widthCalculator;
  final double Function(double)? heightCalculator;

  const ResponsiveImage(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.widthCalculator,
    this.heightCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final finalWidth = widthCalculator?.call(screenWidth) ?? width;
    final finalHeight = heightCalculator?.call(screenHeight) ?? height;

    return Image(
      image: image,
      width: finalWidth,
      height: finalHeight,
      fit: fit,
    );
  }
}

/// SizedBox responsive
class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final double Function(BuildContext)? widthCalculator;
  final double Function(BuildContext)? heightCalculator;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
    this.widthCalculator,
    this.heightCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final finalWidth = widthCalculator?.call(context) ?? width;
    final finalHeight = heightCalculator?.call(context) ?? height;

    return SizedBox(width: finalWidth, height: finalHeight, child: child);
  }
}
