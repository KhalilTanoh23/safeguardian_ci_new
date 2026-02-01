import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';
import 'package:safeguardian_ci_new/presentation/theme/typography.dart';

/// AppBar SILENTOPS avec design moderne et fonctionnalités avancées
class SilentOpsAppBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onNotificationTap;
  final VoidCallback onQRCodeTap;
  final VoidCallback onMenuTap;

  const SilentOpsAppBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onNotificationTap,
    required this.onQRCodeTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark.withValues(alpha: 0.95),
            AppColors.backgroundDark.withValues(alpha: 0.9),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Bouton menu hamburger
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue,',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  userName,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Boutons d'action
          Row(
            children: [
              // Bouton QR Code
              GestureDetector(
                onTap: onQRCodeTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.warningYellow,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Bouton notifications
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceDark,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

