// lib/presentation/widgets/common/emergency_button.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';

class EmergencyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isConnected;
  final bool isLoading;

  const EmergencyButton({
    super.key,
    required this.onPressed,
    required this.isConnected,
    this.isLoading = false,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isPressed = false;
  Timer? _pressTimer;
  int _pressDuration = 0;
  final int _requiredPressDuration = 3; // secondes

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 1.05 : _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isConnected
                    ? AppColors.emergencyRed
                    : AppColors.textSecondary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyRed.withValues(
                      alpha: widget.isConnected ? 128 : 51,
                    ),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 51),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    widget.isConnected
                        ? AppColors.emergencyRed
                        : AppColors.textSecondary,
                    widget.isConnected
                        ? AppColors.emergencyDark
                        : Colors.grey[700]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: widget.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Icon(
                            widget.isConnected
                                ? Icons.emergency
                                : Icons.warning,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),

                  // Animation de pulsation
                  if (widget.isConnected)
                    CustomPaint(
                      painter: PulsePainter(
                        animation: _pulseAnimation.value,
                        color: AppColors.emergencyRed.withValues(alpha: 77),
                      ),
                    ),

                  // Indicateur de pression
                  if (_isPressed)
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: _pressDuration / _requiredPressDuration,
                        strokeWidth: 4,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),

                  // Instructions
                  if (!_isPressed)
                    Positioned(
                      bottom: -25,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Maintenez ${_requiredPressDuration}s',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isConnected || widget.isLoading) return;

    setState(() {
      _isPressed = true;
      _pressDuration = 0;
    });

    _pressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _pressDuration++;
      });

      if (_pressDuration >= _requiredPressDuration) {
        timer.cancel();
        _triggerEmergency();
      }
    });
  }

  void _handleTapUp(TapUpDetails details) {
    _resetPress();
  }

  void _handleTapCancel() {
    _resetPress();
  }

  void _resetPress() {
    _pressTimer?.cancel();
    setState(() {
      _isPressed = false;
      _pressDuration = 0;
    });
  }

  void _triggerEmergency() {
    _resetPress();
    widget.onPressed();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pressTimer?.cancel();
    super.dispose();
  }
}

class PulsePainter extends CustomPainter {
  final double animation;
  final Color color;

  PulsePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * (1 + animation * 0.5);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant PulsePainter oldDelegate) {
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}
