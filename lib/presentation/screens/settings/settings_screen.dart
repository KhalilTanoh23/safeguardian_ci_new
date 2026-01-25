import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safeguardian_ci_new/core/constants/routes.dart';
import 'package:safeguardian_ci_new/core/services/bluetooth_service.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emergencyAlertsEnabled = true;
  bool _smsAutoEnabled = true;

  static const String _kEmergencyAlertsKey = 'emergency_alerts_enabled';
  static const String _kSmsAutoKey = 'sms_auto_enabled';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emergencyAlertsEnabled = prefs.getBool(_kEmergencyAlertsKey) ?? true;
      _smsAutoEnabled = prefs.getBool(_kSmsAutoKey) ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onEmergencyAlertsChanged(bool value) {
    setState(() => _emergencyAlertsEnabled = value);
    _savePreference(_kEmergencyAlertsKey, value);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés')));
  }

  void _onSmsAutoChanged(bool value) {
    setState(() => _smsAutoEnabled = value);
    _savePreference(_kSmsAutoKey, value);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés')));
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _sectionTitle('Compte'),
          _settingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Modifier le profil',
            subtitle: 'Informations personnelles',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _settingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Sécurité du compte',
            subtitle: 'Mot de passe et accès',
            onTap: () {},
          ),

          const SizedBox(height: 30),

          _sectionTitle('Alertes & Urgence'),
          _switchTile(
            icon: Icons.notifications_active_rounded,
            title: 'Alertes d’urgence',
            subtitle: 'Notifications critiques',
            value: _emergencyAlertsEnabled,
            onChanged: _onEmergencyAlertsChanged,
          ),
          _switchTile(
            icon: Icons.sms_failed_rounded,
            title: 'SMS automatiques',
            subtitle: 'Envoyer SMS aux contacts',
            value: _smsAutoEnabled,
            onChanged: _onSmsAutoChanged,
          ),

          const SizedBox(height: 30),

          _sectionTitle('Bracelet & Appareil'),
          _settingsTile(
            icon: Icons.watch_rounded,
            title: 'Bracelet connecté',
            subtitle: bluetoothService.isConnected
                ? 'Appareil actif'
                : 'Aucun appareil connecté',
            onTap: () => Navigator.pushNamed(context, AppRoutes.pairDevice),
          ),
          _settingsTile(
            icon: Icons.battery_charging_full_rounded,
            title: 'État de la batterie',
            subtitle: 'Surveillance du bracelet',
            onTap: () {},
          ),

          const SizedBox(height: 30),

          _sectionTitle('Localisation'),
          _settingsTile(
            icon: Icons.location_on_outlined,
            title: 'Autorisation GPS',
            subtitle: 'Position en cas d’urgence',
            onTap: () {},
          ),

          const SizedBox(height: 40),

          _dangerTile(
            context,
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer le compte',
            onTap: () => _confirmDelete(context, authBloc),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF2563EB)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFF2563EB)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFEF4444)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthBloc authBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est définitive. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Utilise l'événement correct défini dans AuthBloc
              authBloc.add(AuthLogoutRequested());
            },
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }
}
