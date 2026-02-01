import 'package:flutter/material.dart';

/// 📁 SafeGuardian CI - Gestion des Documents
/// Projet SILENTOPS - Équipe MIAGE
/// Stockage sécurisé + Système d'objets perdus avec QR codes

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // 📄 Documents SafeGuardian (contexte ivoirien)
  final List<Map<String, dynamic>> _documents = [
    {
      'icon': Icons.badge_rounded,
      'title': 'Carte d\'identité nationale',
      'subtitle': 'Expire le 15/06/2027',
      'category': 'Identité',
      'date': DateTime(2024, 12, 15),
      'size': '2.4 MB',
      'color': const Color(0xFF3B82F6),
      'hasQR': true,
      'isLost': false,
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Carte étudiant INPHB',
      'subtitle': 'Année 2024-2025',
      'category': 'Éducation',
      'date': DateTime(2024, 11, 20),
      'size': '1.2 MB',
      'color': const Color(0xFFF59E0B),
      'hasQR': true,
      'isLost': false,
    },
    {
      'icon': Icons.medical_services_rounded,
      'title': 'Carnet de vaccination',
      'subtitle': 'À jour - Fièvre jaune valide',
      'category': 'Santé',
      'date': DateTime(2024, 10, 5),
      'size': '1.8 MB',
      'color': const Color(0xFF10B981),
      'hasQR': true,
      'isLost': false,
    },
    {
      'icon': Icons.directions_car_rounded,
      'title': 'Carte grise véhicule',
      'subtitle': 'Toyota Corolla - AA 1234 CI',
      'category': 'Transport',
      'date': DateTime(2024, 9, 12),
      'size': '2.1 MB',
      'color': const Color(0xFFEF4444),
      'hasQR': true,
      'isLost': false,
    },
    {
      'icon': Icons.account_balance_rounded,
      'title': 'Carte Visa SGCI',
      'subtitle': 'Expire 12/2027',
      'category': 'Finance',
      'date': DateTime(2024, 8, 20),
      'size': '0.9 MB',
      'color': const Color(0xFF8B5CF6),
      'hasQR': false,
      'isLost': false,
    },
    {
      'icon': Icons.work_rounded,
      'title': 'Badge entreprise',
      'subtitle': 'PERDU - Publié sur réseau',
      'category': 'Professionnel',
      'date': DateTime(2024, 12, 20),
      'size': '1.1 MB',
      'color': const Color(0xFF06B6D4),
      'hasQR': true,
      'isLost': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _documents
        : _documents
              .where(
                (d) =>
                    d['title'].toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    d['category'].toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildStorage()),
              SliverToBoxAdapter(child: _buildSearch()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildTabs()),
              if (filtered.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => _buildDocCard(filtered[i], i),
                      childCount: filtered.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Documents Sécurisés',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.3),
                const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: 20,
                child: Icon(
                  Icons.cloud_upload_rounded,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.05),
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
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
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
                      'Stockage chiffré + QR codes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
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
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          tooltip: 'Ajouter un document',
          onPressed: _addDocument,
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: _showMenu,
        ),
      ],
    );
  }

  Widget _buildStorage() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Espace de stockage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.45,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4.5 GB utilisés',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              Text(
                '10 GB disponibles',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher un document...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : Icon(Icons.tune_rounded, color: Colors.white.withValues(alpha: 0.5)),
          filled: true,
          fillColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _actionCard(
            Icons.camera_alt_rounded,
            'Scanner',
            const Color(0xFF3B82F6),
          ),
          _actionCard(
            Icons.upload_file_rounded,
            'Importer',
            const Color(0xFF8B5CF6),
          ),
          _actionCard(
            Icons.qr_code_rounded,
            'QR Codes',
            const Color(0xFF10B981),
          ),
          _actionCard(
            Icons.search_rounded,
            'Objets perdus',
            const Color(0xFFF59E0B),
          ),
          _actionCard(
            Icons.archive_rounded,
            'Archives',
            const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
        tabs: const [
          Tab(text: 'Tous'),
          Tab(text: 'Récents'),
          Tab(text: 'Perdus'),
          Tab(text: 'Partagés'),
        ],
      ),
    );
  }

  Widget _buildDocCard(Map<String, dynamic> doc, int index) {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: doc['isLost']
                ? const Color(0xFFF59E0B)
                : Colors.white.withValues(alpha: 0.1),
            width: doc['isLost'] ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    doc['color'].withValues(alpha: 0.3),
                    doc['color'].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(doc['icon'], color: doc['color'], size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doc['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (doc['hasQR'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.qr_code_rounded,
                                color: Color(0xFF3B82F6),
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'QR',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (doc['isLost']) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Color(0xFFF59E0B),
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PERDU',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doc['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doc['date'].day}/${doc['date'].month}/${doc['date'].year}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.storage_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doc['size'],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (c) => [
                _menuItem(Icons.visibility_rounded, 'Voir'),
                _menuItem(Icons.qr_code_rounded, 'QR Code'),
                _menuItem(Icons.share_rounded, 'Partager'),
                _menuItem(Icons.download_rounded, 'Télécharger'),
                if (!doc['isLost'])
                  _menuItem(
                    Icons.warning_rounded,
                    'Déclarer perdu',
                    color: const Color(0xFFF59E0B),
                  ),
                _menuItem(
                  Icons.delete_rounded,
                  'Supprimer',
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem _menuItem(IconData icon, String text, {Color? color}) {
    return PopupMenuItem(
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.white70),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color ?? Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 120,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun document',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Commencez à sécuriser vos documents\navec SafeGuardian CI',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
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
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            _menuTile(Icons.settings_rounded, 'Paramètres'),
            _menuTile(Icons.cloud_download_rounded, 'Synchronisation'),
            _menuTile(Icons.qr_code_scanner_rounded, 'Scanner QR'),
            _menuTile(Icons.help_rounded, 'Aide'),
          ],
        ),
      ),
    );
  }

  void _addDocument() {
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
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ajouter un document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            _addDocumentOption(
              icon: Icons.image_rounded,
              title: 'Prendre une photo',
              subtitle: 'Photographier un document',
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.pop(context),
            ),
            _addDocumentOption(
              icon: Icons.folder_rounded,
              title: 'Importer depuis le téléphone',
              subtitle: 'Sélectionner depuis la galerie',
              color: const Color(0xFF10B981),
              onTap: () => Navigator.pop(context),
            ),
            _addDocumentOption(
              icon: Icons.cloud_upload_rounded,
              title: 'Synchroniser depuis le cloud',
              subtitle: 'Google Drive, OneDrive, etc.',
              color: const Color(0xFFF59E0B),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addDocumentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

