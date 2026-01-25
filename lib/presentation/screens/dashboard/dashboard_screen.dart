import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:safeguardian_ci_new/presentation/bloc/emergency_bloc/emergency_bloc.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/alert_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/contact_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/item_card.dart';
import 'package:safeguardian_ci_new/core/services/bluetooth_service.dart';
import 'package:safeguardian_ci_new/core/constants/routes.dart';
import 'package:safeguardian_ci_new/presentation/screens/contacts/contacts_screen.dart'
    as contacts_screen;
import 'package:safeguardian_ci_new/presentation/screens/items/items_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/documents/documents_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/main/qr_scanner_screen.dart';
import 'package:safeguardian_ci_new/data/models/alert.dart';
import 'package:safeguardian_ci_new/data/models/emergency_contact.dart';
import 'package:safeguardian_ci_new/data/models/item.dart';
import 'package:safeguardian_ci_new/data/repositories/alert_repository.dart';
import 'package:safeguardian_ci_new/data/repositories/contact_repository.dart';
import 'package:safeguardian_ci_new/data/repositories/item_repository.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';
import 'package:safeguardian_ci_new/presentation/theme/typography.dart';
import 'package:safeguardian_ci_new/presentation/widgets/navigation/silentops_navbar.dart';
import 'package:safeguardian_ci_new/presentation/widgets/navigation/silentops_appbar.dart';
import 'package:safeguardian_ci_new/presentation/widgets/emergency/sos_button.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/feature_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/status_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/stat_card.dart';
import 'package:safeguardian_ci_new/presentation/widgets/cards/activity_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isInitialized = false;

  // Real data loaded from repositories
  List<EmergencyAlert> _recentAlerts = [];
  List<Contact> _contacts = [];
  List<ValuedItem> _recentItems = [];
  bool _isLoadingData = true;

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'alert',
      'title': 'Alerte résolue',
      'description': 'Alerte de sécurité résolue',
      'time': 'Il y a 5 min',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.successGreen,
    },
    {
      'type': 'contact',
      'title': 'Contact ajouté',
      'description': 'Marie Yvann ajoutée',
      'time': 'Il y a 2h',
      'icon': Icons.person_add_rounded,
      'color': AppColors.primary,
    },
    {
      'type': 'device',
      'title': 'Bracelet synchronisé',
      'description': 'Dernière synchro réussie',
      'time': 'Il y a 4h',
      'icon': Icons.watch_rounded,
      'color': AppColors.secondary,
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.location_on_rounded,
      'title': 'Localisation',
      'description': 'En temps réel',
      'color': AppColors.primary,
      'route': AppRoutes.contacts,
    },
    {
      'icon': Icons.qr_code_rounded,
      'title': 'QR Code',
      'description': 'Vos documents',
      'color': AppColors.warningYellow,
      'route': null,
      'action': 'scanQR',
    },
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Bracelet',
      'description': 'Connecté & Sécurisé',
      'color': AppColors.successGreen,
      'route': AppRoutes.pairDevice,
    },
    {
      'icon': Icons.shield_rounded,
      'title': 'Mode discret',
      'description': 'Activé',
      'color': AppColors.secondary,
      'route': null,
      'action': 'toggleDiscreet',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadDashboardData();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Fond avec éléments décoratifs subtils
          _buildBackground(),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // AppBar moderne SILENTOPS
                if (_selectedIndex == 0) _buildSilentOpsAppBar(context),

                // Contenu des pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _selectedIndex = index),
                    children: [
                      _buildDashboardPage(bluetoothService),
                      const contacts_screen.EmergencyContactsScreen(),
                      const ItemsScreen(),
                      const DocumentsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton SOS flottant
          Positioned(
            bottom: 100,
            right: 24,
            child: SOSButton(
              pulseAnimation: _pulseAnimation,
              onPressed: () => _handleEmergency(context),
            ),
          ),

          // Navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SilentOpsNavBar(
              currentIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                _pageController.jumpToPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundDark, Color(0xFF0F172A)],
          stops: [0.1, 0.9],
        ),
      ),
      child: Stack(
        children: [
          // Éléments décoratifs SILENTOPS
          Positioned(
            top: 50,
            left: 20,
            child: Opacity(
              opacity: 0.05,
              child: Text(
                'SILENT',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: Opacity(
              opacity: 0.05,
              child: Text(
                'OPS',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilentOpsAppBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return SilentOpsAppBar(
            userName: "${state.user.firstName} ${state.user.lastName}",
            userEmail: state.user.email,
            onNotificationTap: () => _goToAlerts(context),
            onQRCodeTap: () => _scanQRCode(context),
            onMenuTap: () =>
                _showMenuSheet(context, BlocProvider.of<AuthBloc>(context)),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDashboardPage(BluetoothService bluetoothService) {
    return AnimatedOpacity(
      opacity: _isInitialized ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          // Section de bienvenue
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // Carte de statut
          StatusCard(
            isConnected: bluetoothService.isConnected,
            batteryLevel: 75,
            lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
            onConnectPressed: () => _pairDevice(context),
          ),
          const SizedBox(height: 24),

          // Carrousel des fonctionnalités
          _buildFeaturesSection(),
          const SizedBox(height: 24),

          // Grille de statistiques
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Activités récentes
          _buildRecentActivities(),
          const SizedBox(height: 24),

          // Alertes récentes
          if (_recentAlerts.isNotEmpty) ...[
            _buildSectionHeader(
              'Alertes récentes',
              Icons.warning_amber_rounded,
              AppColors.errorRed,
              () => _goToAlerts(context),
            ),
            const SizedBox(height: 16),
            ..._recentAlerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(alert: alert),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Contacts d'urgence
          if (_contacts.isNotEmpty) ...[
            _buildSectionHeader(
              'Contacts d\'urgence',
              Icons.people_rounded,
              AppColors.primary,
              () => _goToContacts(context),
            ),
            const SizedBox(height: 16),
            ..._contacts
                .take(2)
                .map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ContactCard(contact: contact),
                  ),
                ),
            const SizedBox(height: 24),
          ],

          // Objets protégés
          if (_recentItems.isNotEmpty) ...[
            _buildSectionHeader(
              'Objets protégés',
              Icons.inventory_2_rounded,
              AppColors.successGreen,
              () => _goToItems(context),
            ),
            const SizedBox(height: 16),
            ..._recentItems
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ItemCard(item: item),
                  ),
                ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
        ? 'Bon après-midi'
        : 'Bonsoir';
    final emoji = hour < 12
        ? '☀️'
        : hour < 18
        ? '⛅'
        : '🌙';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            '$emoji $greeting',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Votre sécurité, notre mission.',
          style: AppTypography.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SafeGuardian-CI vous protège discrètement et efficacement.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Fonctionnalités',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _features.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final feature = _features[index];
              return FeatureCard(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
                color: feature['color'] as Color,
                onTap: () {
                  if (feature['route'] != null) {
                    Navigator.pushNamed(context, feature['route'] as String);
                  } else if (feature['action'] == 'scanQR') {
                    _scanQRCode(context);
                  } else if (feature['action'] == 'toggleDiscreet') {
                    _toggleDiscreetMode(context);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.contacts_rounded,
                value: '${_contacts.length}',
                label: 'Contacts',
                color: AppColors.primary,
                onTap: () => _goToContacts(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_rounded,
                value: '${_recentItems.length}',
                label: 'Objets',
                color: AppColors.successGreen,
                onTap: () => _goToItems(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                value: '${_recentAlerts.length}',
                label: 'Alertes',
                color: AppColors.errorRed,
                onTap: () => _goToAlerts(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.document_scanner_rounded,
                value: '3',
                label: 'Documents',
                color: AppColors.warningYellow,
                onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Activités récentes',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._recentActivities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(
                icon: activity['icon'] as IconData,
                title: activity['title'] as String,
                description: activity['description'] as String,
                time: activity['time'] as String,
                color: activity['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Touchez pour voir tout',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showMenuSheet(BuildContext context, AuthBloc authBloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // En-tête du menu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Menu principal',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Options du menu
            _buildMenuOption(
              icon: Icons.person_rounded,
              title: 'Mon profil',
              subtitle: 'Gérer vos informations',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),

            _buildMenuOption(
              icon: Icons.settings_rounded,
              title: 'Paramètres',
              subtitle: 'Personnaliser l\'application',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),

            _buildMenuOption(
              icon: Icons.help_rounded,
              title: 'Centre d\'aide',
              subtitle: 'FAQ et support',
              color: AppColors.successGreen,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.helpCenter);
              },
            ),

            _buildMenuOption(
              icon: Icons.privacy_tip_rounded,
              title: 'Confidentialité',
              subtitle: 'Vos données sont protégées',
              color: AppColors.warningYellow,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.privacy);
              },
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.borderDark, height: 1),
            const SizedBox(height: 24),

            // Déconnexion
            _buildMenuOption(
              icon: Icons.logout_rounded,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter du compte',
              color: AppColors.errorRed,
              isDanger: true,
              onTap: () {
                Navigator.pop(context);
                _confirmLogout(context, authBloc);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDanger
              ? AppColors.errorRed.withOpacity(0.1)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDanger
                ? AppColors.errorRed.withOpacity(0.3)
                : AppColors.borderDark,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDanger ? AppColors.errorRed : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDanger ? AppColors.errorRed : AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmergency(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.errorRed.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(
                    Icons.emergency_rounded,
                    color: AppColors.errorRed,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ALERTE D\'URGENCE',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tous vos contacts d\'urgence recevront votre position et un signal de détresse.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: AppColors.borderDark),
                      ),
                      child: const Text(
                        'ANNULER',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sendEmergencyAlert(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONFIRMER',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmergencyAlert(BuildContext context) {
    final emergencyBloc = BlocProvider.of<EmergencyBloc>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);

    if (authBloc.state is AuthAuthenticated) {
      final user = (authBloc.state as AuthAuthenticated).user;

      emergencyBloc.add(
        EmergencyTriggered(
          userId: user.id,
          userName: user.fullName,
          message: 'Alerte d\'urgence déclenchée manuellement',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alerte envoyée à vos contacts d\'urgence',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context, AuthBloc authBloc) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.errorRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Déconnexion',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: AppColors.borderDark),
                      ),
                      child: const Text(
                        'ANNULER',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authBloc.add(AuthLogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'DÉCONNECTER',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToAlerts(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.alertHistory);
  }

  void _scanQRCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  void _pairDevice(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.pairDevice);
  }

  void _goToContacts(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.contacts);
  }

  void _goToItems(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.items);
  }

  void _toggleDiscreetMode(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final state = authBloc.state;

    if (state is AuthAuthenticated) {
      final currentValue = state.user.settings.discreetMode;
      authBloc.add(
        AuthUpdateSettingsRequested({'discreetMode': !currentValue}),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mode discret ${!currentValue ? 'activé' : 'désactivé'}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadDashboardData() async {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final state = authBloc.state;

    if (state is AuthAuthenticated) {
      final userId = state.user.id;

      try {
        final alerts = await AlertRepository().getAlertsForUser(userId);
        final contacts = await ContactRepository().getContactsForUser(userId);
        final items = await ItemRepository().getItemsForUser(userId);

        if (mounted) {
          setState(() {
            _recentAlerts = alerts;
            _contacts = contacts;
            _recentItems = items;
            _isLoadingData = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
      }
    }
  }
}
