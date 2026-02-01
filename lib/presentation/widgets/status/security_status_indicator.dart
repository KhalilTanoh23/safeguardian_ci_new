import 'package:flutter/material.dart';

/// Indicateur du statut de sécurité
class SecurityStatusIndicator extends StatelessWidget {
  final bool isSecure;
  final String label;
  final double size;

  const SecurityStatusIndicator({
    super.key,
    required this.isSecure,
    this.label = 'Sécurisé',
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isSecure ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSecure ? Icons.check : Icons.close,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isSecure ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
