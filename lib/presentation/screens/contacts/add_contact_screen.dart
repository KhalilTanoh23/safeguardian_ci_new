import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:safeguardian_ci_new/data/models/emergency_contact.dart';
import 'package:safeguardian_ci_new/presentation/bloc/contacts_bloc/contacts_bloc.dart';

/// 🔐 SafeGuardian CI - Ajout/Modification de Contact d'Urgence
/// Projet SILENTOPS - Équipe MIAGE
/// Système d'alerte intelligent avec bracelet/bague IoT

class AddEmergencyContactScreen extends StatefulWidget {
  final EmergencyContact? contact;
  const AddEmergencyContactScreen({super.key, this.contact});

  @override
  State<AddEmergencyContactScreen> createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // 📝 Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // 🎯 Catégories de contacts selon SafeGuardian CI
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Famille Proche',
      'icon': Icons.family_restroom_rounded,
      'color': const Color(0xFFEC4899),
      'relations': [
        {'name': 'Mère', 'icon': Icons.woman_rounded},
        {'name': 'Père', 'icon': Icons.man_rounded},
        {'name': 'Frère/Sœur', 'icon': Icons.people_rounded},
        {'name': 'Tuteur légal', 'icon': Icons.shield_rounded},
      ],
    },
    {
      'name': 'Partenaire',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFEF4444),
      'relations': [
        {'name': 'Époux/Épouse', 'icon': Icons.favorite_rounded},
        {'name': 'Fiancé(e)', 'icon': Icons.favorite_border_rounded},
      ],
    },
    {
      'name': 'Réseau Social',
      'icon': Icons.people_alt_rounded,
      'color': const Color(0xFF3B82F6),
      'relations': [
        {'name': 'Meilleur ami', 'icon': Icons.people_rounded},
        {'name': 'Collègue', 'icon': Icons.work_rounded},
        {'name': 'Voisin', 'icon': Icons.home_rounded},
      ],
    },
    {
      'name': 'Services d\'Urgence',
      'icon': Icons.emergency_rounded,
      'color': const Color(0xFFEF4444),
      'relations': [
        {'name': 'Police (111)', 'icon': Icons.local_police_rounded},
        {'name': 'SAMU (185)', 'icon': Icons.local_hospital_rounded},
        {'name': 'Pompiers (180)', 'icon': Icons.fire_truck_rounded},
        {'name': 'Médecin personnel', 'icon': Icons.medical_services_rounded},
      ],
    },
  ];

  // ⚡ Système d'escalade intelligent
  final List<Map<String, dynamic>> _priorities = [
    {
      'level': 1,
      'label': 'IMMÉDIATE',
      'desc': 'Notification dans les 15 secondes',
      'tech': 'SMS + Push + Appel auto',
      'color': const Color(0xFFEF4444),
      'time': '15s',
    },
    {
      'level': 2,
      'label': 'HAUTE',
      'desc': 'Alerte sous 30 secondes',
      'tech': 'SMS + Push notification',
      'color': const Color(0xFFF97316),
      'time': '30s',
    },
    {
      'level': 3,
      'label': 'STANDARD',
      'desc': 'Notification sous 1 minute',
      'tech': 'Push + SMS différé',
      'color': const Color(0xFF3B82F6),
      'time': '1min',
    },
    {
      'level': 4,
      'label': 'ESCALADE',
      'desc': 'Alerte communautaire (rayon 1km)',
      'tech': 'Réseau SafeGuardian activé',
      'color': const Color(0xFF8B5CF6),
      'time': '2min+',
    },
  ];

  // 📌 État du formulaire
  String? _selectedRelationship;
  int? _selectedPriority;
  bool _canSeeLiveLocation = true;
  bool _canReceiveSMS = true;
  bool _canReceivePush = true;
  bool _isEmergencyService = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();

    // 🔄 Pré-remplir si modification
    if (widget.contact != null) {
      _nameCtrl.text = widget.contact!.name;
      _phoneCtrl.text = widget.contact!.phone;
      _emailCtrl.text = widget.contact!.email;
      _selectedRelationship = widget.contact!.relationship;
      _selectedPriority = widget.contact!.priority;
      _canSeeLiveLocation = widget.contact!.canSeeLiveLocation;
      _canReceiveSMS = true; // Par défaut
      _canReceivePush = true; // Par défaut
      _isEmergencyService = widget.contact!.isVerified;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHero(),
                          const SizedBox(height: 30),
                          _buildCategories(),
                          const SizedBox(height: 30),
                          _buildPriorities(),
                          const SizedBox(height: 30),
                          _buildForm(),
                          const SizedBox(height: 30),
                          _buildSettings(),
                          const SizedBox(height: 40),
                          _buildActions(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== APP BAR ==========
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((255 * 0.3).toInt()),
        border: Border(
          bottom: BorderSide(color: Colors.white.withAlpha((255 * 0.1).toInt())),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.1).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact == null
                      ? 'Nouveau Contact'
                      : 'Modifier Contact',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'SafeGuardian CI',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.6).toInt()),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.1).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
              onPressed: _showHelp,
            ),
          ),
        ],
      ),
    );
  }

  // ========== HERO SECTION ==========
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha((255 * 0.4).toInt()),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.25).toInt()),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SafeGuardian CI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Alerté automatiquement lors d\'une urgence détectée par votre bracelet/bague connecté(e)',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.95).toInt()),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CATEGORIES ==========
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Catégorie & Relation', Icons.group_rounded),
        const SizedBox(height: 16),
        ..._categories.map((cat) => _buildCategoryCard(cat)),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((255 * 0.1).toInt())),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cat['color'].withAlpha((255 * 0.2).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat['icon'], color: cat['color'], size: 22),
          ),
          title: Text(
            cat['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (cat['relations'] as List).map((rel) {
                  final selected = _selectedRelationship == rel['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRelationship = rel['name'];
                        _isEmergencyService =
                            cat['name'] == 'Services d\'Urgence';
                        if (_isEmergencyService) {
                          _canSeeLiveLocation = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                colors: [
                                  cat['color'].withAlpha((255 * 0.6).toInt()),
                                  cat['color'].withAlpha((255 * 0.3).toInt()),
                                ],
                              )
                            : null,
                        color: selected ? null : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? cat['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            rel['icon'],
                            color: selected ? Colors.white : Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            rel['name'],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== PRIORITIES ==========
  Widget _buildPriorities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Niveau de Priorité', Icons.speed_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withAlpha((255 * 0.1).toInt()),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3B82F6).withAlpha((255 * 0.3).toInt())),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_rounded,
                color: Color(0xFF3B82F6),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Escalade automatique : alerte communautaire après 2 min sans réponse (rayon 1km)',
                  style: TextStyle(
                    color: const Color(0xFF3B82F6),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._priorities.map((p) {
          final selected = _selectedPriority == p['level'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = p['level']),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            p['color'].withAlpha((255 * 0.3).toInt()),
                            p['color'].withAlpha((255 * 0.1).toInt()),
                          ],
                        )
                      : null,
                  color: selected
                      ? null
                      : const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? p['color']
                        : Colors.white.withAlpha((255 * 0.1).toInt()),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: p['color'].withAlpha((255 * 0.2).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.access_time_rounded,
                        color: p['color'],
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p['label'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p['color'].withAlpha((255 * 0.2).toInt()),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p['time'],
                                  style: TextStyle(
                                    color: p['color'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['desc'],
                            style: TextStyle(
                              color: Colors.white.withAlpha((255 * 0.7).toInt()),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📡 ${p['tech']}',
                            style: TextStyle(
                              color: p['color'].withAlpha((255 * 0.7).toInt()),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========== FORM ==========
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informations', Icons.contact_page_rounded),
        const SizedBox(height: 16),
        _textField(
          'Nom complet *',
          'Ex: Kouassi Jean-Marc',
          Icons.person_rounded,
          _nameCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Nom requis' : null,
        ),
        const SizedBox(height: 14),
        _textField(
          'Téléphone *',
          '+225 07 XX XX XX XX',
          Icons.phone_rounded,
          _phoneCtrl,
          type: TextInputType.phone,
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Téléphone requis';
            if (!RegExp(r'^\+?[0-9\s\-\(\)]+$').hasMatch(v!)) {
              return 'Format invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _textField(
          'Email',
          'contact@exemple.ci',
          Icons.email_rounded,
          _emailCtrl,
          type: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // ========== SETTINGS ==========
  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Configuration', Icons.settings_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha((255 * 0.1).toInt())),
          ),
          child: Column(
            children: [
              _switch(
                Icons.my_location_rounded,
                'GPS en temps réel',
                'Position actualisée pendant alerte',
                _canSeeLiveLocation,
                _isEmergencyService
                    ? null
                    : (v) => setState(() => _canSeeLiveLocation = v),
                const Color(0xFF3B82F6),
              ),
              Divider(color: Colors.white.withAlpha((255 * 0.1).toInt()), height: 28),
              _switch(
                Icons.sms_rounded,
                'Alertes SMS',
                'SMS automatiques d\'urgence',
                _canReceiveSMS,
                (v) => setState(() => _canReceiveSMS = v),
                const Color(0xFF10B981),
              ),
              Divider(color: Colors.white.withAlpha((255 * 0.1).toInt()), height: 28),
              _switch(
                Icons.notifications_active_rounded,
                'Push',
                'Notifications instantanées',
                _canReceivePush,
                (v) => setState(() => _canReceivePush = v),
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== ACTIONS ==========
  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.contact == null
                          ? Icons.add_circle_rounded
                          : Icons.edit_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.contact == null
                          ? 'Ajouter au réseau'
                          : 'Mettre à jour',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
          label: const Text('Scanner QR SafeGuardian'),
          onPressed: _scanQR,
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
        ),
      ],
    );
  }

  // ========== HELPER WIDGETS ==========
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha((255 * 0.9).toInt()),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withAlpha((255 * 0.3).toInt()),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switch(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    void Function(bool)? onChanged,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.2).toInt()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.6).toInt()),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          inactiveThumbColor: Colors.grey,
        ),
      ],
    );
  }

  // ========== ACTIONS ==========
  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_selectedRelationship == null || _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complétez tous les champs requis'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final color = _priorities.firstWhere(
      (p) => p['level'] == _selectedPriority,
    )['color'];
    final contact = EmergencyContact(
      id:
          widget.contact?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      name: _nameCtrl.text,
      relationship: _selectedRelationship!,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : '',
      priority: _selectedPriority!,
      color: color,
      isVerified: _isEmergencyService,
      canSeeLiveLocation: _canSeeLiveLocation,
      lastAlert: null,
      responseTime: 'N/A',
      addedDate: DateTime.now(),
    );

    if (widget.contact == null) {
      context.read<ContactsBloc>().add(AddContact(contact));
    } else {
      context.read<ContactsBloc>().add(UpdateContact(contact));
    }
    Navigator.pop(context, contact);
  }

  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Scanner QR SafeGuardian'),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  final data = barcode.rawValue!.split(':');
                  if (data.length >= 3 && data[0] == 'SAFEGUARDIAN') {
                    setState(() {
                      _nameCtrl.text = data[1];
                      _phoneCtrl.text = data[2];
                      if (data.length > 3) _emailCtrl.text = data[3];
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contact scanné: ${data[1]}'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.help_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Aide SafeGuardian CI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔐 Système d\'alerte intelligent\n',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                '• Contacts alertés par ordre de priorité\n'
                '• Localisation GPS en temps réel\n'
                '• Escalade automatique après 2 min\n'
                '• Alerte communautaire (rayon 1km)\n\n'
                'Intégration bracelet/bague IoT',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

