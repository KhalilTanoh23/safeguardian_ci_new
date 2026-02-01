// lib/presentation/screens/emergency/emergency_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safeguardian_ci_new/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:safeguardian_ci_new/presentation/bloc/emergency_bloc/emergency_bloc.dart';
import 'package:safeguardian_ci_new/presentation/widgets/dialogs/emergency_dialog.dart';
import 'package:safeguardian_ci_new/data/models/alert.dart';
import 'package:safeguardian_ci_new/data/models/contact.dart';
import 'package:safeguardian_ci_new/data/repositories/contact_repository.dart';
import 'package:safeguardian_ci_new/data/repositories/alert_repository.dart';
import 'package:safeguardian_ci_new/presentation/theme/colors.dart';
import 'package:safeguardian_ci_new/presentation/theme/typography.dart';
import 'package:safeguardian_ci_new/core/constants/routes.dart';
import 'package:safeguardian_ci_new/presentation/screens/emergency/alert_map_screen.dart';
import 'package:safeguardian_ci_new/core/services/location_service.dart'
    as concrete_location;

class EmergencyScreen extends StatefulWidget {
  final Map<String, dynamic>? alertData;

  const EmergencyScreen({super.key, this.alertData});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  EmergencyAlert? _currentAlert;
  bool _isAlertActive = false;
  Timer? _countdownTimer;
  int _countdownSeconds = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    _initializeAlert();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeAlert() {
    if (widget.alertData != null) {
      _currentAlert = EmergencyAlert.fromJson(widget.alertData!);
      _isAlertActive = _currentAlert!.status == AlertStatus.pending;

      if (_isAlertActive) {
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        _triggerCommunityAlert();
      }
    });
  }

  void _triggerCommunityAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.people, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Alerte Communautaire'),
          ],
        ),
        content: const Text(
          'Aucun de vos contacts n\'a répondu à l\'alerte.\n\n'
          'Les personnes proches de vous vont être notifiées '
          'pour vous porter assistance.\n\n'
          'Cette alerte sera également transmise aux autorités.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('COMPRIS'),
          ),
        ],
      ),
    );

    // Envoyer l'alerte communautaire via le bloc
    final emergencyBloc = BlocProvider.of<EmergencyBloc>(context);
    if (_currentAlert != null) {
      emergencyBloc.add(CommunityAlertSent(alert: _currentAlert!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre d\'Urgence'),
        backgroundColor: _isAlertActive
            ? AppColors.emergencyRed
            : AppColors.primary,
        actions: [
          if (_isAlertActive)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelAlert,
              tooltip: 'Annuler l\'alerte',
            ),
        ],
      ),
      body: _isAlertActive
          ? _buildActiveAlertView()
          : _buildEmergencyDashboard(),
      floatingActionButton: _isAlertActive
          ? null
          : FloatingActionButton.extended(
              onPressed: _triggerEmergency,
              icon: const Icon(Icons.emergency),
              label: const Text('ALERTE URGENCE'),
              backgroundColor: AppColors.emergencyRed,
            ),
    );
  }

  Widget _buildEmergencyDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section urgence
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 50,
                    color: AppColors.emergencyRed,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bouton d\'Urgence',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Appuyez pour envoyer une alerte à tous vos contacts '
                  'et aux autorités si nécessaire.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _triggerEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency),
                      SizedBox(width: 12),
                      Text(
                        'DÉCLENCHER L\'ALERTE',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Contacts d'urgence
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacts d\'Urgence',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEmergencyContacts(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _manageContacts(),
                    icon: const Icon(Icons.edit),
                    label: const Text('Gérer les contacts'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Instructions d'urgence
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Que faire en cas d\'urgence?',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEmergencyInstructions(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Historique des alertes
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Historique des Alertes',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _viewAlertHistory(),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentAlerts(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContacts() {
    return FutureBuilder<List<Contact>>(
      future: _getEmergencyContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur lors du chargement des contacts: ${snapshot.error}',
            ),
          );
        }

        final contacts = snapshot.data ?? [];

        // Add police contact
        final allContacts = [
          ...contacts,
          Contact(
            id: 'police',
            userId: 'system',
            name: 'Police',
            phone: '111',
            email: '',
            relationship: 'Autorité',
            isEmergencyContact: true,
            priority: 0,
            addedDate: DateTime.now(),
          ),
        ];

        return Column(
          children: allContacts.map((contact) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 26),
                child: Icon(
                  contact.relationship == 'Autorité'
                      ? Icons.security
                      : Icons.person,
                  color: AppColors.primary,
                ),
              ),
              title: Text(contact.name),
              subtitle: Text('${contact.relationship} • ${contact.phone}'),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: AppColors.primary),
                onPressed: () => _callContact(contact.phone),
              ),
              onTap: () => _viewContactDetails(contact),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<Contact>> _getEmergencyContacts() async {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is AuthAuthenticated) {
      final user = (authBloc.state as AuthAuthenticated).user;
      final contactRepository = ContactRepository();
      return await contactRepository.getEmergencyContacts(user.id);
    }
    return [];
  }

  Widget _buildEmergencyInstructions() {
    return Column(
      children: [
        _buildInstructionStep(
          number: 1,
          title: 'Restez calme',
          description:
              'Prenez une profonde respiration et évaluez la situation',
        ),
        _buildInstructionStep(
          number: 2,
          title: 'Déclenchez l\'alerte',
          description:
              'Appuyez sur le bouton d\'urgence ou utilisez votre bracelet',
        ),
        _buildInstructionStep(
          number: 3,
          title: 'Attendez les secours',
          description:
              'Restez en sécurité pendant que vos contacts sont notifiés',
        ),
        _buildInstructionStep(
          number: 4,
          title: 'Communiquez',
          description: 'Répondez aux appels et messages de vos contacts',
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return FutureBuilder<List<EmergencyAlert>>(
      future: _getRecentAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur lors du chargement des alertes: ${snapshot.error}',
            ),
          );
        }

        final alerts = snapshot.data ?? [];

        if (alerts.isEmpty) {
          return const Center(child: Text('Aucune alerte récente'));
        }

        return Column(
          children: alerts.map((alert) {
            final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
            final formattedDate = dateFormat.format(alert.timestamp);

            String statusText;
            Color statusColor;
            IconData statusIcon;

            switch (alert.status) {
              case AlertStatus.resolved:
                statusText = 'Résolue';
                statusColor = AppColors.safeGreen;
                statusIcon = Icons.check_circle;
                break;
              case AlertStatus.cancelled:
                statusText = 'Annulée';
                statusColor = AppColors.warningYellow;
                statusIcon = Icons.cancel;
                break;
              case AlertStatus.pending:
                statusText = 'En cours';
                statusColor = AppColors.emergencyRed;
                statusIcon = Icons.warning;
                break;
              default:
                statusText = 'Inconnue';
                statusColor = AppColors.textSecondary;
                statusIcon = Icons.help;
            }

            return ListTile(
              leading: Icon(statusIcon, color: statusColor),
              title: const Text('Alerte d\'urgence'),
              subtitle: Text(formattedDate),
              trailing: Chip(
                label: Text(statusText),
                backgroundColor: statusColor.withValues(alpha: 26),
                labelStyle: TextStyle(color: statusColor),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<EmergencyAlert>> _getRecentAlerts() async {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is AuthAuthenticated) {
      final user = (authBloc.state as AuthAuthenticated).user;
      final alertRepository = AlertRepository();
      return await alertRepository.getRecentAlerts(user.id, limit: 3);
    }
    return [];
  }

  Widget _buildActiveAlertView() {
    return Column(
      children: [
        // Compte à rebours
        Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.emergencyRed.withValues(alpha: 26),
          child: Column(
            children: [
              Text(
                'ALERTE D\'URGENCE ACTIVE',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.emergencyRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vos contacts ont été notifiés',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              CircularCountDownTimer(
                duration: _countdownSeconds,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.grey[200] ?? Colors.grey,
                color: AppColors.emergencyRed,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                isReverse: true,
                onComplete: _triggerCommunityAlert,
              ),
              const SizedBox(height: 10),
              Text(
                'Alerte communautaire dans',
                style: AppTypography.bodyMedium,
              ),
              Text(
                '${_countdownSeconds ~/ 60}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emergencyRed,
                ),
              ),
            ],
          ),
        ),

        // Carte de localisation
        Expanded(
          child: _currentAlert != null
              ? AlertMapScreen(
                  alertLocation: _currentAlert!.location,
                  alertId: _currentAlert!.id,
                )
              : const Center(child: Text('Chargement de la localisation...')),
        ),

        // Actions rapides
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 26),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.call,
                label: 'Appeler\nPolice',
                onPressed: _callPolice,
                color: AppColors.emergencyRed,
              ),
              _buildActionButton(
                icon: Icons.message,
                label: 'Message\nurgence',
                onPressed: _sendEmergencyMessage,
                color: AppColors.primary,
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Partager\nlocalisation',
                onPressed: _shareLocation,
                color: AppColors.secondary,
              ),
              _buildActionButton(
                icon: Icons.cancel,
                label: 'Annuler\nalerte',
                onPressed: _cancelAlert,
                color: AppColors.warningYellow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 26),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _triggerEmergency() {
    showDialog(
      context: context,
      builder: (context) => EmergencyDialog(
        onConfirm: () {
          Navigator.pop(context);
          _sendEmergencyAlert();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _sendEmergencyAlert() {
    final emergencyBloc = BlocProvider.of<EmergencyBloc>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);

    if (authBloc.state is AuthAuthenticated) {
      final user = (authBloc.state as AuthAuthenticated).user;

      emergencyBloc.add(
        EmergencyTriggered(
          userId: user.id,
          userName: user.fullName,
          message: 'Alerte d\'urgence déclenchée',
        ),
      );

      setState(() {
        _isAlertActive = true;
        _currentAlert = EmergencyAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          location: const LatLng(0, 0), // Remplacé par la position réelle
          timestamp: DateTime.now(),
          status: AlertStatus.pending,
        );
        _startCountdown();
      });
    }
  }

  void _callPolice() async {
    const emergencyNumber = '111';
    final url = Uri.parse('tel:$emergencyNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel téléphonique'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  void _sendEmergencyMessage() async {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is AuthAuthenticated) {
      final user = (authBloc.state as AuthAuthenticated).user;
      final contactRepository = ContactRepository();
      final contacts = await contactRepository.getEmergencyContacts(user.id);

      if (contacts.isNotEmpty) {
        final message =
            'URGENCE: ${user.fullName} a déclenché une alerte d\'urgence. Localisation: ${_currentAlert?.location.toString() ?? "Non disponible"}';
        final phoneNumbers = contacts.map((c) => c.phone).join(';');

        final url = Uri.parse(
          'sms:$phoneNumbers?body=${Uri.encodeComponent(message)}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'envoyer le message SMS'),
              backgroundColor: AppColors.emergencyRed,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun contact d\'urgence configuré'),
            backgroundColor: AppColors.warningYellow,
          ),
        );
      }
    }
  }

  void _shareLocation() async {
    final locationService = concrete_location.LocationService();
    try {
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        // Using share_plus package to share the location
        // Since share_plus is not imported, we'll use url_launcher to open maps
        final url = Uri.parse(
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: AppColors.emergencyRed,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localisation non disponible'),
            backgroundColor: AppColors.emergencyRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'obtention de la localisation: $e'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  void _cancelAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler l\'alerte'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette alerte? '
          'Tous vos contacts seront notifiés de l\'annulation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NON'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningYellow,
            ),
            onPressed: () {
              Navigator.pop(context);
              _confirmCancelAlert();
            },
            child: const Text('OUI, ANNULER'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelAlert() {
    if (_currentAlert != null) {
      final emergencyBloc = BlocProvider.of<EmergencyBloc>(context);
      emergencyBloc.add(
        EmergencyCancelled(
          alertId: _currentAlert!.id,
          reason: 'Annulée manuellement par l\'utilisateur',
        ),
      );

      setState(() {
        _isAlertActive = false;
        _countdownTimer?.cancel();
        _countdownSeconds = 180;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerte annulée'),
          backgroundColor: AppColors.warningYellow,
        ),
      );
    }
  }

  void _callContact(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel téléphonique'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  void _viewContactDetails(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 26),
              child: Icon(
                contact.relationship == 'Autorité'
                    ? Icons.security
                    : Icons.person,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(contact.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Téléphone: ${contact.phone}'),
            if (contact.email.isNotEmpty) Text('Email: ${contact.email}'),
            Text('Relation: ${contact.relationship}'),
            if (contact.isEmergencyContact)
              const Text('Contact d\'urgence: Oui'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _callContact(contact.phone);
            },
            icon: const Icon(Icons.call),
            label: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _manageContacts() {
    Navigator.pushNamed(context, AppRoutes.contacts);
  }

  void _viewAlertHistory() {
    Navigator.pushNamed(context, AppRoutes.alertHistory);
  }
}

// Widget compte à rebours circulaire (simplifié)
class CircularCountDownTimer extends StatelessWidget {
  final int duration;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Color backgroundColor;
  final Color color;
  final TextStyle textStyle;
  final bool isReverse;
  final VoidCallback onComplete;

  const CircularCountDownTimer({
    super.key,
    required this.duration,
    this.strokeWidth = 10,
    this.strokeCap = StrokeCap.round,
    this.backgroundColor = Colors.grey,
    this.color = Colors.blue,
    this.textStyle = const TextStyle(fontSize: 20),
    this.isReverse = false,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: isReverse ? 1 - (duration / 180) : duration / 180,
            strokeWidth: strokeWidth,
            strokeCap: strokeCap,
            backgroundColor: backgroundColor,
            color: color,
          ),
          Text(
            '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
