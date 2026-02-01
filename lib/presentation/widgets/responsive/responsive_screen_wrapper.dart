import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/core/utils/responsive_helper.dart';

/// Wrapper d'écran avec gestion responsivité intégrée
class ResponsiveScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? drawer;
  final bool centerTitle;
  final bool showAppBar;
  final EdgeInsets? bodyPadding;
  final Widget? bottomNavigationBar;

  const ResponsiveScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.backgroundColor,
    this.drawer,
    this.centerTitle = true,
    this.showAppBar = true,
    this.bodyPadding,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: showAppBar
          ? (appBar ??
                AppBar(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: centerTitle,
                  elevation: 0,
                  actions: actions,
                ))
          : null,
      drawer: drawer,
      body: SingleChildScrollView(
        child: Padding(
          padding: bodyPadding ?? EdgeInsets.all(responsive.paddingMedium),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Card responsive pour afficher du contenu
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final void Function()? onTap;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? 2,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadius ?? BorderRadius.circular(responsive.radiusMedium),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(responsive.paddingMedium),
          child: child,
        ),
      ),
    );
  }
}

/// Bouton responsive
class ResponsiveButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;

  const ResponsiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final height = this.height ?? responsive.buttonHeight;
    final width = this.width ?? double.infinity;

    final style = TextStyle(
      fontSize: responsive.fontSizeNormal,
      fontWeight: FontWeight.w600,
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radiusMedium),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: responsive.iconSizeMedium,
                width: responsive.iconSizeMedium,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: responsive.iconSizeSmall),
                    SizedBox(width: responsive.spacerSmall),
                  ],
                  Text(label, style: textStyle ?? style),
                ],
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radiusMedium),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: responsive.iconSizeMedium,
              width: responsive.iconSizeMedium,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: responsive.iconSizeSmall),
                  SizedBox(width: responsive.spacerSmall),
                ],
                Text(label, style: textStyle ?? style),
              ],
            ),
    );
  }
}

/// Section avec titre responsive
class ResponsiveSection extends StatelessWidget {
  final String title;
  final Widget child;
  final void Function()? onSeeMore;
  final bool showSeeMore;
  final EdgeInsets? padding;

  const ResponsiveSection({
    super.key,
    required this.title,
    required this.child,
    this.onSeeMore,
    this.showSeeMore = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(vertical: responsive.spacerLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              if (showSeeMore)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Text(
                    'Voir plus',
                    style: TextStyle(
                      fontSize: responsive.fontSizeSmall,
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.spacerMedium),
          child,
        ],
      ),
    );
  }
}

/// ListView responsive
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Padding(
      padding: padding ?? EdgeInsets.all(responsive.paddingMedium),
      child: ListView(
        physics: physics,
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(
                  bottom: scrollDirection == Axis.vertical
                      ? responsive.spacerSmall
                      : 0,
                  right: scrollDirection == Axis.horizontal
                      ? responsive.spacerSmall
                      : 0,
                ),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Input responsive
class ResponsiveInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const ResponsiveInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSizeNormal,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: responsive.spacerSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(fontSize: responsive.fontSizeNormal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: responsive.fontSizeSmall),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radiusMedium),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.paddingMedium,
              vertical: responsive.paddingMedium,
            ),
          ),
        ),
      ],
    );
  }
}
