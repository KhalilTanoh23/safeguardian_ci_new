import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeguardian_ci_new/core/constants/routes.dart';
import 'package:safeguardian_ci_new/core/services/bluetooth_service.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen>
    with SingleTickerProviderStateMixin {
  // Paramètres d'alerte
  bool _emergencyAlertsEnabled = true;
  bool _communityAlertsEnabled = true;
  bool _smsAutoEnabled = true;
  bool _callAutoEnabled = false;

  // Paramètres de notification
  bool _pushNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Paramètres de localisation
  bool _backgroundLocationEnabled = true;
  bool _highAccuracyGpsEnabled = true;

  // Paramètres de confidentialité
  bool _shareLocationWithContacts = true;
  bool _anonymousInCommunity = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Keys pour SharedPreferences
  static const String _kEmergencyAlertsKey = 'emergency_alerts_enabled';
  static const String _kCommunityAlertsKey = 'community_alerts_enabled';
  static const String _kSmsAutoKey = 'sms_auto_enabled';
  static const String _kCallAutoKey = 'call_auto_enabled';
  static const String _kPushNotifKey = 'push_notifications_enabled';
  static const String _kSoundKey = 'sound_enabled';
  static const String _kVibrationKey = 'vibration_enabled';
  static const String _kBackgroundLocationKey = 'background_location_enabled';
  static const String _kHighAccuracyGpsKey = 'high_accuracy_gps_enabled';
  static const String _kShareLocationKey = 'share_location_with_contacts';
  static const String _kAnonymousKey = 'anonymous_in_community';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _emergencyAlertsEnabled = prefs.getBool(_kEmergencyAlertsKey) ?? true;
        _communityAlertsEnabled = prefs.getBool(_kCommunityAlertsKey) ?? true;
        _smsAutoEnabled = prefs.getBool(_kSmsAutoKey) ?? true;
        _callAutoEnabled = prefs.getBool(_kCallAutoKey) ?? false;
        _pushNotificationsEnabled = prefs.getBool(_kPushNotifKey) ?? true;
        _soundEnabled = prefs.getBool(_kSoundKey) ?? true;
        _vibrationEnabled = prefs.getBool(_kVibrationKey) ?? true;
        _backgroundLocationEnabled =
            prefs.getBool(_kBackgroundLocationKey) ?? true;
        _highAccuracyGpsEnabled = prefs.getBool(_kHighAccuracyGpsKey) ?? true;
        _shareLocationWithContacts = prefs.getBool(_kShareLocationKey) ?? true;
        _anonymousInCommunity = prefs.getBool(_kAnonymousKey) ?? false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    _showSnackBar('Paramètre enregistré', const Color(0xFF10B981));
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Compte
                    _buildAccountSection(context),
                    const SizedBox(height: 24),

                    // Section Alertes & Urgence
                    _buildAlertsSection(),
                    const SizedBox(height: 24),

                    // Section Notifications
                    _buildNotificationsSection(),
                    const SizedBox(height: 24),

                    // Section Bracelet
                    _buildDeviceSection(context, bluetoothService),
                    const SizedBox(height: 24),

                    // Section Localisation
                    _buildLocationSection(),
                    const SizedBox(height: 24),

                    // Section Confidentialité
                    _buildPrivacySection(),
                    const SizedBox(height: 24),

                    // Section Support
                    _buildSupportSection(context),
                    const SizedBox(height: 24),

                    // Zone Danger
                    _buildDangerZone(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ SLIVER APP BAR ============
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Paramètres',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Personnalisez votre expérience SafeGuardian',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ SECTION COMPTE ============
  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      title: 'Compte',
      icon: Icons.person_rounded,
      iconGradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      children: [
        _buildNavigationTile(
          context: context,
          icon: Icons.person_outline_rounded,
          title: 'Informations personnelles',
          subtitle: 'Nom, email, téléphone',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.lock_outline_rounded,
          title: 'Sécurité du compte',
          subtitle: 'Mot de passe et authentification',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.contacts_rounded,
          title: 'Contacts de confiance',
          subtitle: 'Gérer vos contacts d\'urgence',
          route: AppRoutes.contacts,
          gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        ),
      ],
    );
  }

  // ============ SECTION ALERTES ============
  Widget _buildAlertsSection() {
    return _buildSection(
      title: 'Alertes & Urgence',
      icon: Icons.notifications_active_rounded,
      iconGradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      children: [
        _buildSwitchTile(
          icon: Icons.emergency_rounded,
          title: 'Alertes d\'urgence',
          subtitle: 'Notifications critiques immédiates',
          value: _emergencyAlertsEnabled,
          gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          onChanged: (value) {
            setState(() => _emergencyAlertsEnabled = value);
            _savePreference(_kEmergencyAlertsKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.groups_rounded,
          title: 'Alertes communautaires',
          subtitle: 'Recevoir alertes de la communauté (1km)',
          value: _communityAlertsEnabled,
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          onChanged: (value) {
            setState(() => _communityAlertsEnabled = value);
            _savePreference(_kCommunityAlertsKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.sms_rounded,
          title: 'SMS automatiques',
          subtitle: 'Envoyer SMS aux contacts en urgence',
          value: _smsAutoEnabled,
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          onChanged: (value) {
            setState(() => _smsAutoEnabled = value);
            _savePreference(_kSmsAutoKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.call_rounded,
          title: 'Appels automatiques',
          subtitle: 'Appeler contacts si non-réponse (3 min)',
          value: _callAutoEnabled,
          gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
          onChanged: (value) {
            setState(() => _callAutoEnabled = value);
            _savePreference(_kCallAutoKey, value);
          },
        ),
      ],
    );
  }

  // ============ SECTION NOTIFICATIONS ============
  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      iconGradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications push',
          subtitle: 'Recevoir notifications sur l\'appareil',
          value: _pushNotificationsEnabled,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
          onChanged: (value) {
            setState(() => _pushNotificationsEnabled = value);
            _savePreference(_kPushNotifKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.volume_up_rounded,
          title: 'Son',
          subtitle: 'Activer son des notifications',
          value: _soundEnabled,
          gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            _savePreference(_kSoundKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.vibration_rounded,
          title: 'Vibration',
          subtitle: 'Activer vibration des notifications',
          value: _vibrationEnabled,
          gradient: [const Color(0xFFA855F7), const Color(0xFF9333EA)],
          onChanged: (value) {
            setState(() => _vibrationEnabled = value);
            _savePreference(_kVibrationKey, value);
          },
        ),
      ],
    );
  }

  // ============ SECTION BRACELET ============
  Widget _buildDeviceSection(BuildContext context, BluetoothService bluetooth) {
    final isConnected = bluetooth.isConnected;

    return _buildSection(
      title: 'Bracelet & Appareil',
      icon: Icons.watch_rounded,
      iconGradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      children: [
        // Statut connexion
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isConnected
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    (isConnected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isConnected
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Bracelet connecté' : 'Non connecté',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConnected
                          ? 'SafeGuard Smart Band • Protection active'
                          : 'Connectez votre bracelet pour la protection',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isConnected)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),

        _buildNavigationTile(
          context: context,
          icon: Icons.bluetooth_searching_rounded,
          title: 'Appairer un bracelet',
          subtitle: 'Connecter un nouvel appareil',
          route: AppRoutes.pairDevice,
          gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.battery_charging_full_rounded,
          title: 'État de la batterie',
          subtitle: isConnected
              ? 'Batterie 87% • Autonomie 3 jours'
              : 'Non disponible',
          route: AppRoutes.pairDevice,
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.update_rounded,
          title: 'Mise à jour firmware',
          subtitle: 'Version 2.1.4 (dernière)',
          route: AppRoutes.pairDevice,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
        ),
      ],
    );
  }

  // ============ SECTION LOCALISATION ============
  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Localisation',
      icon: Icons.location_on_rounded,
      iconGradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: const Color(0xFFD97706),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'La localisation est essentielle pour les alertes d\'urgence',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildSwitchTile(
          icon: Icons.my_location_rounded,
          title: 'Localisation en arrière-plan',
          subtitle: 'Suivi GPS actif lors d\'une alerte',
          value: _backgroundLocationEnabled,
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          onChanged: (value) {
            setState(() => _backgroundLocationEnabled = value);
            _savePreference(_kBackgroundLocationKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.gps_fixed_rounded,
          title: 'GPS haute précision',
          subtitle: 'Meilleure précision (consomme plus)',
          value: _highAccuracyGpsEnabled,
          gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          onChanged: (value) {
            setState(() => _highAccuracyGpsEnabled = value);
            _savePreference(_kHighAccuracyGpsKey, value);
          },
        ),
      ],
    );
  }

  // ============ SECTION CONFIDENTIALITÉ ============
  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Confidentialité & Sécurité',
      icon: Icons.shield_rounded,
      iconGradient: [const Color(0xFF10B981), const Color(0xFF059669)],
      children: [
        _buildSwitchTile(
          icon: Icons.share_location_rounded,
          title: 'Partager position avec contacts',
          subtitle: 'Contacts peuvent voir votre position',
          value: _shareLocationWithContacts,
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          onChanged: (value) {
            setState(() => _shareLocationWithContacts = value);
            _savePreference(_kShareLocationKey, value);
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.person_off_rounded,
          title: 'Mode anonyme (communauté)',
          subtitle: 'Masquer identité alertes publiques',
          value: _anonymousInCommunity,
          gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          onChanged: (value) {
            setState(() => _anonymousInCommunity = value);
            _savePreference(_kAnonymousKey, value);
          },
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.security_rounded,
          title: 'Données personnelles',
          subtitle: 'Gérer et exporter vos données',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.policy_rounded,
          title: 'Politique de confidentialité',
          subtitle: 'Lire notre politique RGPD',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        ),
      ],
    );
  }

  // ============ SECTION SUPPORT ============
  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      title: 'Support & Informations',
      icon: Icons.help_rounded,
      iconGradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      children: [
        _buildNavigationTile(
          context: context,
          icon: Icons.help_center_rounded,
          title: 'Centre d\'aide',
          subtitle: 'FAQ et guides d\'utilisation',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.feedback_rounded,
          title: 'Envoyer un feedback',
          subtitle: 'Aidez-nous à améliorer SafeGuardian',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.bug_report_rounded,
          title: 'Signaler un bug',
          subtitle: 'Rapporter un problème technique',
          route: AppRoutes.profile,
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        ),
        _buildDivider(),
        _buildNavigationTile(
          context: context,
          icon: Icons.info_rounded,
          title: 'À propos',
          subtitle: 'Version 1.0.0 • By SILENTOPS',
          route: AppRoutes.profile,
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
      ],
    );
  }

  // ============ ZONE DANGER ============
  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Zone Danger',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildDangerTile(
            context: context,
            icon: Icons.delete_forever_rounded,
            title: 'Supprimer le compte',
            subtitle: 'Action irréversible et définitive',
            onTap: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  // ============ WIDGETS HELPER ============
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Color> iconGradient,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: iconGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required List<Color> gradient,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required List<Color> gradient,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: gradient[0],
            activeTrackColor: gradient[0].withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: const Color(0xFFEF4444).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
    );
  }

  // ============ DIALOGUES ============
  void _confirmDelete(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Supprimer le compte',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cette action est définitive et irréversible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Vous perdrez :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Tous vos contacts de confiance',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• L\'historique de vos alertes',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Vos objets et documents enregistrés',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• La configuration de votre bracelet',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          authBloc.add(AuthLogoutRequested());
                          _showSnackBar(
                            'Compte supprimé',
                            const Color(0xFFEF4444),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
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
}
