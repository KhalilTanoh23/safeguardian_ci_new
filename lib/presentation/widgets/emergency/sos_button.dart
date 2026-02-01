import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';

/// Bouton SOS flottant avec animation de pulsation
class SOSButton extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onPressed;

  const SOSButton({
    super.key,
    required this.pulseAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.errorRed.withValues(alpha: 0.9), AppColors.errorRed],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorRed.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

