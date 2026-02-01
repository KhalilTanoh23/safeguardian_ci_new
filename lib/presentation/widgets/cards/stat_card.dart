import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';
import 'package:safeguardian_ci_new/presentation/theme/typography.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final int? maxValue;
  final bool isDanger;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.maxValue,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxValue != null ? value / maxValue! : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDanger ? AppColors.errorRed : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: AppTypography.headlineMedium.copyWith(
              color: isDanger ? AppColors.errorRed : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (maxValue != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDanger ? AppColors.errorRed : color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

