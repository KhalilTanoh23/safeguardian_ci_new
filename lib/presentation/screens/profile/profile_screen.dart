import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:safeguardian_ci_new/core/services/bluetooth_service.dart';
import 'package:safeguardian_ci_new/core/constants/routes.dart';
import 'package:safeguardian_ci_new/data/repositories/alert_repository.dart';
import 'package:safeguardian_ci_new/data/repositories/contact_repository.dart';
import 'package:safeguardian_ci_new/data/repositories/item_repository.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';
import 'package:safeguardian_ci_new/presentation/theme/typography.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/stat_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/info_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/buttons/quick_action_button.dart';
import 'package:safeguardian_ci_new/presentation/widgets/status/security_status_indicator.dart';
import 'package:safeguardian_ci_new/presentation/widgets/lists/settings_list_tile.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _contactsCount = 0;
  int _alertsCount = 0;
  int _itemsCount = 0;
  int _documentsCount = 0;
  bool _isLoadingStats = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final state = authBloc.state;

    if (state is AuthAuthenticated) {
      final userId = state.user.id;

      try {
        final contacts = await ContactRepository().getContactsForUser(userId);
        final alerts = await AlertRepository().getAlertsForUser(userId);
        final items = await ItemRepository().getItemsForUser(userId);
        final documents = await ApiService().getDocuments();

        if (mounted) {
          setState(() {
            _contactsCount = contacts.length;
            _alertsCount = alerts.length;
            _itemsCount = items.length;
            _documentsCount = documents.length;
            _isLoadingStats = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    }
  }

  Future<void> _updateUserSetting(String settingName, bool value) async {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final state = authBloc.state;

    if (state is AuthAuthenticated) {
      try {
        // Map setting name to the correct field
        Map<String, dynamic> settingsUpdate = {};
        switch (settingName) {
          case 'Notifications':
            settingsUpdate['notificationsEnabled'] = value;
            break;
          case 'Authentification biométrique':
            settingsUpdate['biometricAuth'] = value;
            break;
          case 'Localisation en temps réel':
            settingsUpdate['locationSharing'] = value;
            break;
          case 'Mode discret':
            settingsUpdate['discreetMode'] = value;
            break;
          case 'Connexion auto bracelet':
            settingsUpdate['autoConnectBracelet'] = value;
            break;
        }

        if (settingsUpdate.isNotEmpty) {
          authBloc.add(AuthUpdateSettingsRequested(settingsUpdate));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$settingName ${value ? 'activé' : 'désactivé'}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour du paramètre'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar avec avatar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary.withOpacity(0.95),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Text(
                      "${state.user.firstName} ${state.user.lastName}",
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.9),
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  );
                } else if (state is AuthUnauthenticated) {
                  return SliverFillRemaining(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is AuthError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Erreur: ${state.message}",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  final user = state.user;

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Statut de sécurité
                      SecurityStatusIndicator(
                        isConnected: bluetoothService.isConnected,
                        lastSync: DateTime.now().subtract(
                          const Duration(minutes: 5),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions rapides
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Actions rapides",
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                QuickActionButton(
                                  icon: Icons.emergency_rounded,
                                  label: "Urgence",
                                  color: AppColors.accent,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.emergency,
                                  ),
                                  isImportant: true,
                                ),
                                QuickActionButton(
                                  icon: Icons.contacts_rounded,
                                  label: "Contacts",
                                  color: AppColors.secondary,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.contacts,
                                  ),
                                ),
                                QuickActionButton(
                                  icon: Icons.warning_amber_rounded,
                                  label: "Alertes",
                                  color: AppColors.warningYellow,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.alertHistory,
                                  ),
                                ),
                                QuickActionButton(
                                  icon: Icons.qr_code_rounded,
                                  label: "QR Code",
                                  color: AppColors.infoBlue,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.qrScanner,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Statistiques
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Statistiques de protection",
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "SILENTOPS",
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _isLoadingStats
                                ? _buildStatsShimmer()
                                : GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    children: [
                                      StatCard(
                                        icon: Icons.contacts_rounded,
                                        value: _contactsCount,
                                        label: "Contacts",
                                        color: AppColors.secondary,
                                        maxValue: 10,
                                      ),
                                      StatCard(
                                        icon: Icons.warning_amber_rounded,
                                        value: _alertsCount,
                                        label: "Alertes",
                                        color: AppColors.warningYellow,
                                        isDanger: true,
                                      ),
                                      StatCard(
                                        icon: Icons.inventory_2_rounded,
                                        value: _itemsCount,
                                        label: "Objets",
                                        color: AppColors.infoBlue,
                                      ),
                                      StatCard(
                                        icon: Icons.description_rounded,
                                        value: _documentsCount,
                                        label: "Documents",
                                        color: AppColors.successGreen,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Informations personnelles
                      InfoCard(
                        title: "Informations personnelles",
                        icon: Icons.person_rounded,
                        children: [
                          _buildInfoRow(
                            "Email",
                            user.email,
                            Icons.email_rounded,
                          ),
                          _buildInfoRow(
                            "Téléphone",
                            user.phone,
                            Icons.phone_rounded,
                          ),
                          if (user.emergencyInfo?.bloodType != null)
                            _buildInfoRow(
                              "Groupe sanguin",
                              user.emergencyInfo!.bloodType!,
                              Icons.bloodtype_rounded,
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Paramètres de sécurité
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderDark,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security_rounded,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Paramètres de sécurité",
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSecuritySetting(
                              "Notifications",
                              user.settings.notificationsEnabled,
                              Icons.notifications_rounded,
                            ),
                            _buildSecuritySetting(
                              "Authentification biométrique",
                              user.settings.biometricAuth,
                              Icons.fingerprint_rounded,
                            ),
                            _buildSecuritySetting(
                              "Localisation en temps réel",
                              user.settings.locationSharing,
                              Icons.location_on_rounded,
                            ),
                            _buildSecuritySetting(
                              "Mode discret",
                              user.settings.discreetMode,
                              Icons.visibility_off_rounded,
                            ),
                            _buildSecuritySetting(
                              "Connexion auto bracelet",
                              user.settings.autoConnectBracelet,
                              Icons.bluetooth_connected_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Navigation
                      SettingsListTile(
                        icon: Icons.edit_rounded,
                        title: "Modifier le profil",
                        subtitle: "Mettre à jour vos informations",
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.settings),
                        trailing: Icons.arrow_forward_ios_rounded,
                        color: AppColors.infoBlue,
                      ),
                      SettingsListTile(
                        icon: Icons.contacts_rounded,
                        title: "Contacts d'urgence",
                        subtitle: "Gérer vos contacts de confiance",
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.contacts),
                        trailing: Icons.arrow_forward_ios_rounded,
                        color: AppColors.secondary,
                      ),
                      SettingsListTile(
                        icon: Icons.inventory_2_rounded,
                        title: "Objets protégés",
                        subtitle: "Vos objets enregistrés",
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.items),
                        trailing: Icons.arrow_forward_ios_rounded,
                        color: AppColors.successGreen,
                      ),
                      SettingsListTile(
                        icon: Icons.description_rounded,
                        title: "Documents officiels",
                        subtitle: "CNI, passeport, permis...",
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.documents),
                        trailing: Icons.arrow_forward_ios_rounded,
                        color: AppColors.warningYellow,
                      ),
                      SettingsListTile(
                        icon: Icons.watch_rounded,
                        title: "Appareil connecté",
                        subtitle: "Gérer votre bracelet/bague",
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.pairDevice),
                        trailing: Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: 32),

                      // Bouton déconnexion
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            authBloc.add(AuthLogoutRequested());
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text("Se déconnecter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed.withOpacity(
                              0.2,
                            ),
                            foregroundColor: AppColors.errorRed,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.errorRed.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            textStyle: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: Text(
                          "SafeGuardian-CI • SILENTOPS",
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ]),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySetting(String label, bool isEnabled, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? AppColors.successGreen
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled ? "Activé" : "Désactivé",
                  style: AppTypography.bodySmall.copyWith(
                    color: isEnabled
                        ? AppColors.successGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => _updateUserSetting(label, value),
            activeColor: AppColors.accent,
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.accent.withOpacity(0.5);
              }
              return AppColors.borderDark;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: AppColors.surfaceDark,
          highlightColor: AppColors.borderDark,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}
