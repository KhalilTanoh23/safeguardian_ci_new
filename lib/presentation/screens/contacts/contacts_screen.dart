import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeguardian_ci_new/data/models/emergency_contact.dart';
import 'package:safeguardian_ci_new/presentation/bloc/contacts_bloc/contacts_bloc.dart';
import 'package:safeguardian_ci_new/presentation/screens/contacts/add_contact_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _searchQuery = '';
  EmergencyContact? _selectedContact;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    // Charger les contacts au démarrage
    context.read<ContactsBloc>().add(LoadContacts());
  }

  @override
  void dispose() {
    _animController.dispose();
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
          child: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              final List<EmergencyContact> contacts = state is ContactsLoaded
                  ? List<EmergencyContact>.from(state.contacts)
                  : [];
              final filtered = _searchQuery.isEmpty
                  ? contacts
                  : contacts
                        .where(
                          (c) =>
                              c.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              c.phone.contains(_searchQuery) ||
                              c.relationship.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  if (_selectedContact != null)
                    _buildSelectedCard(_selectedContact!),
                  SliverToBoxAdapter(child: _buildStats(contacts)),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildEscaladeBanner()),
                  if (filtered.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (c, i) => _buildContactCard(filtered[i], i),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: _addContact,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: _selectedContact != null ? _buildBottomBar() : null,
    );
  }

  // ========== APP BAR ==========
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Réseau SafeGuardian',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Stack(
          children: [
            Positioned(
              right: -40,
              top: 20,
              child: Icon(
                Icons.security_rounded,
                size: 180,
                color: Colors.white.withAlpha((255 * 0.05).toInt()),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF6366F1,
                      ).withAlpha((255 * 0.3).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(
                          0xFF6366F1,
                        ).withAlpha((255 * 0.5).toInt()),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'SafeGuardian CI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alertés lors d\'une urgence bracelet/bague',
                    style: TextStyle(
                      color: Colors.white.withAlpha((255 * 0.8).toInt()),
                      fontSize: 12,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: _showSettings,
        ),
        IconButton(
          icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          onPressed: _showHelp,
        ),
      ],
    );
  }

  // ========== SELECTED CONTACT CARD ==========
  Widget _buildSelectedCard(EmergencyContact contact) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              contact.color.withAlpha((255 * 0.3).toInt()),
              contact.color.withAlpha((255 * 0.1).toInt()),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: contact.color.withAlpha((255 * 0.5).toInt()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: contact.color.withAlpha((255 * 0.3).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: contact.color.withAlpha((255 * 0.3).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.relationship,
                        style: TextStyle(
                          color: Colors.white.withAlpha((255 * 0.8).toInt()),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => setState(() => _selectedContact = null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionBtn(Icons.call_rounded, 'Appeler', () => _call(contact)),
                _actionBtn(
                  Icons.message_rounded,
                  'SMS',
                  () => _message(contact),
                ),
                _actionBtn(
                  Icons.edit_rounded,
                  'Modifier',
                  () => _edit(contact),
                ),
                _actionBtn(
                  Icons.delete_rounded,
                  'Supprimer',
                  () => _delete(contact),
                  destructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== ACTION BUTTON ==========
  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool destructive = false,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: destructive
                ? Colors.red.withAlpha((255 * 0.2).toInt())
                : Colors.white.withAlpha((255 * 0.2).toInt()),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: destructive ? Colors.red : Colors.white,
              size: 22,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: destructive ? Colors.red : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ========== STATS CARD ==========
  Widget _buildStats(List<EmergencyContact> contacts) {
    final verified = contacts.where((c) => c.isVerified).length;
    final avgResponse = _calcAvgResponse(contacts);
    final withGPS = contacts.where((c) => c.canSeeLiveLocation).length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha((255 * 0.1).toInt())),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(
            contacts.length.toString(),
            'Contacts',
            Icons.people_rounded,
            const Color(0xFF3B82F6),
          ),
          _stat(
            verified.toString(),
            'Vérifiés',
            Icons.verified_rounded,
            const Color(0xFF10B981),
          ),
          _stat(
            avgResponse,
            'Temps moy',
            Icons.access_time_rounded,
            const Color(0xFFF97316),
          ),
          _stat(
            withGPS.toString(),
            'GPS',
            Icons.location_on_rounded,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  // ========== STAT ITEM ==========
  Widget _stat(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.2).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha((255 * 0.6).toInt()),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ========== SEARCH BAR ==========
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher un contact...',
          hintStyle: TextStyle(
            color: Colors.white.withAlpha((255 * 0.3).toInt()),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withAlpha((255 * 0.5).toInt()),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withAlpha((255 * 0.1).toInt()),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
      ),
    );
  }

  // ========== ESCALADE BANNER ==========
  Widget _buildEscaladeBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withAlpha((255 * 0.2).toInt()),
            const Color(0xFF8B5CF6).withAlpha((255 * 0.1).toInt()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withAlpha((255 * 0.3).toInt()),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withAlpha((255 * 0.3).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Système d\'escalade automatique',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alerte communautaire après 2 min sans réponse (rayon 1km)',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.7).toInt()),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CONTACT CARD ==========
  Widget _buildContactCard(EmergencyContact contact, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedContact = contact),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withAlpha((255 * 0.5).toInt()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedContact?.id == contact.id
                  ? contact.color.withAlpha((255 * 0.5).toInt())
                  : Colors.white.withAlpha((255 * 0.1).toInt()),
              width: _selectedContact?.id == contact.id ? 2 : 1,
            ),
            boxShadow: _selectedContact?.id == contact.id
                ? [
                    BoxShadow(
                      color: contact.color.withAlpha((255 * 0.2).toInt()),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          contact.color.withAlpha((255 * 0.3).toInt()),
                          contact.color.withAlpha((255 * 0.1).toInt()),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        contact.priority.toString(),
                        style: TextStyle(
                          color: contact.color,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (!contact.isVerified)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (contact.canSeeLiveLocation)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3B82F6,
                              ).withAlpha((255 * 0.2).toInt()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'GPS',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      contact.relationship,
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.7).toInt()),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(
                          Icons.phone_rounded,
                          contact.phone,
                          const Color(0xFF10B981),
                        ),
                        if (contact.lastAlert != null) ...[
                          const SizedBox(width: 8),
                          _chip(
                            Icons.access_time_rounded,
                            contact.responseTime,
                            const Color(0xFFF97316),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: contact.color.withAlpha((255 * 0.2).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Niv ${contact.priority}',
                  style: TextStyle(
                    color: contact.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== CHIP ==========
  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 120,
            color: Colors.white.withAlpha((255 * 0.1).toInt()),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun contact SafeGuardian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajoutez des contacts pour activer\nvotre réseau de sécurité',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha((255 * 0.6).toInt()),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: 24),
            label: const Text(
              'Ajouter un contact',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            onPressed: _addContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== BOTTOM BAR ==========
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha((255 * 0.95).toInt()),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha((255 * 0.1).toInt())),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.swap_vert_rounded, size: 20),
              label: const Text('Changer priorité'),
              onPressed: _changePriority,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334155),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active_rounded, size: 20),
              label: const Text('Test alerte'),
              onPressed: _testAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== HELPER METHODS ==========
  String _calcAvgResponse(List<EmergencyContact> contacts) {
    final withResponse = contacts
        .where(
          (c) =>
              c.lastAlert != null &&
              c.responseTime != 'N/A' &&
              c.responseTime != 'Immédiat',
        )
        .toList();
    if (withResponse.isEmpty) return '--';

    int total = 0;
    for (final c in withResponse) {
      if (c.responseTime.contains('s') && !c.responseTime.contains('m')) {
        total += int.parse(c.responseTime.replaceAll('s', ''));
      } else if (c.responseTime.contains('m')) {
        final parts = c.responseTime.split(' ');
        if (parts.length == 2) {
          total +=
              int.parse(parts[0].replaceAll('m', '')) * 60 +
              int.parse(parts[1].replaceAll('s', ''));
        }
      }
    }
    final avg = total ~/ withResponse.length;
    return avg < 60 ? '${avg}s' : '${avg ~/ 60}m';
  }

  // ========== ACTIONS ==========
  void _addContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const AddEmergencyContactScreen()),
    ).then((result) {
      if (!mounted) return;
      if (result != null && result is EmergencyContact) {
        context.read<ContactsBloc>().add(AddContact(result));
      }
    });
  }

  void _call(EmergencyContact c) async {
    final uri = Uri(scheme: 'tel', path: c.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Impossible de passer l\'appel');
    }
  }

  void _message(EmergencyContact c) async {
    final uri = Uri(scheme: 'sms', path: c.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Impossible d\'ouvrir les SMS');
    }
  }

  void _edit(EmergencyContact c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddEmergencyContactScreen(contact: c),
      ),
    ).then((result) {
      if (!mounted) return;
      if (result != null && result is EmergencyContact) {
        context.read<ContactsBloc>().add(UpdateContact(result));
      }
    });
  }

  void _delete(EmergencyContact c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((255 * 0.2).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir retirer ${c.name} de votre réseau SafeGuardian ?',
          style: TextStyle(color: Colors.white.withAlpha((255 * 0.8).toInt())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ContactsBloc>().add(DeleteContact(c.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _changePriority() {
    if (_selectedContact == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => _buildPrioritySheet(),
    );
  }

  Widget _buildPrioritySheet() {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFF64748B),
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.3).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Changer la priorité',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(6, (i) {
            final level = i + 1;
            final selected = _selectedContact!.priority == level;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  final updated = _selectedContact!.copyWith(priority: level);
                  context.read<ContactsBloc>().add(UpdateContact(updated));
                  setState(() => _selectedContact = updated);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors[i].withAlpha((255 * 0.2).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      level.toString(),
                      style: TextStyle(
                        color: colors[i],
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Niveau $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                      )
                    : null,
                tileColor: selected
                    ? colors[i].withAlpha((255 * 0.1).toInt())
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _testAlert() {
    if (_selectedContact == null) return;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withAlpha((255 * 0.2).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF97316),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Test d\'alerte',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action enverra une alerte de test à ${_selectedContact!.name}.',
              style: TextStyle(
                color: Colors.white.withAlpha((255 * 0.8).toInt()),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha((255 * 0.1).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withAlpha((255 * 0.3).toInt()),
                ),
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
                      'Le contact recevra un SMS indiquant qu\'il s\'agit d\'un test',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              final uri = Uri(
                scheme: 'sms',
                path: _selectedContact!.phone,
                queryParameters: {
                  'body':
                      '🔔 TEST SAFEGUARDIAN CI\n\nCeci est un test d\'alerte. Le système fonctionne correctement. Aucune action requise.\n\n- Projet SILENTOPS',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test envoyé à ${_selectedContact!.name}'),
                    backgroundColor: const Color(0xFFF97316),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else {
                _showError('Impossible d\'envoyer le SMS');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Envoyer le test'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.3).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Paramètres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _settingsTile(
              Icons.notifications_rounded,
              'Notifications d\'urgence',
              'Activer les alertes push',
              true,
            ),
            _settingsTile(
              Icons.share_location_rounded,
              'Partage de localisation',
              'GPS activé pendant les alertes',
              true,
            ),
            _settingsTile(
              Icons.backup_rounded,
              'Sauvegarde automatique',
              'Synchronisation des contacts',
              true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shield_rounded),
                label: const Text('Paramètres de sécurité'),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withAlpha((255 * 0.5).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withAlpha((255 * 0.2).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(width: 14),
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
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              'SafeGuardian CI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔐 Système d\'alerte intelligent',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _helpItem('1', 'Urgence détectée par bracelet/bague IoT'),
              _helpItem('2', 'Contacts alertés par ordre de priorité'),
              _helpItem('3', 'SMS + Push + Localisation GPS partagée'),
              _helpItem('4', 'Escalade automatique après 2 minutes'),
              _helpItem('5', 'Alerte communautaire (rayon 1km)'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withAlpha((255 * 0.2).toInt()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(
                      0xFFF97316,
                    ).withAlpha((255 * 0.3).toInt()),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Conseil : Testez régulièrement le système avec vos contacts',
                        style: TextStyle(
                          color: const Color(0xFFF97316),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text(
              'Compris',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.8).toInt()),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
