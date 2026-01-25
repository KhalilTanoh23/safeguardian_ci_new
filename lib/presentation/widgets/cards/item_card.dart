import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safeguardian_ci_new/data/models/item.dart';

// Replace by your theme colors if you have a centralized colors.dart
const Color primaryColor = Color(0xFF1E3A8A);

class ItemCard extends StatelessWidget {
  final ValuedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onReportLost;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onReportLost,
  });

  // Reuse formats to avoid recreating them on every build
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isLost
              ? const Color(0xFFEF4444).withOpacity(0.4)
              : const Color(0xFFE5E7EB),
          width: item.isLost ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Image or icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: _getCategoryGradient(item.category),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _getCategoryColor(
                          item.category,
                        ).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildItemImage(),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                    fontSize: 17,
                                  ),
                            ),
                          ),
                          if (item.isLost)
                            Semantics(
                              label: 'Item marked as lost',
                              child: _buildLostBadge(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryBadge(),
                      const SizedBox(height: 10),
                      _buildValueAndDate(),
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildTags(),
                      ],
                    ],
                  ),
                ),
                if (!item.isLost && onReportLost != null) ...[
                  const SizedBox(width: 12),
                  _buildReportButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    if (item.photoPath == null || item.photoPath!.trim().isEmpty) {
      return Center(
        child: Icon(
          _getCategoryIcon(item.category),
          size: 36,
          color: Colors.white,
        ),
      );
    }

    final path = item.photoPath!.trim();
    // Simple heuristic: treat http/https paths as network images, otherwise asset.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              _getCategoryIcon(item.category),
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Default to asset (works with packaged assets). If you store file paths, you'll want to swap to Image.file.
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            _getCategoryIcon(item.category),
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLostBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.warning_rounded, color: Colors.white, size: 12),
        SizedBox(width: 4),
        Text(
          'PERDU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _buildCategoryBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _getCategoryColor(item.category).withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getCategoryIcon(item.category),
          size: 14,
          color: _getCategoryColor(item.category),
        ),
        const SizedBox(width: 6),
        Text(
          _getCategoryName(item.category),
          style: TextStyle(
            color: _getCategoryColor(item.category),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _buildValueAndDate() => Row(
    children: [
      if (item.estimatedValue > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payments_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _currencyFormat.format(item.estimatedValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      const SizedBox(width: 8),
      const Icon(
        Icons.calendar_today_rounded,
        size: 13,
        color: Color(0xFF64748B),
      ),
      const SizedBox(width: 4),
      Text(
        _dateFormat.format(item.addedDate),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildTags() => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: item.tags
        .map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget _buildReportButton() => Tooltip(
    message: 'Signaler comme perdu',
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onReportLost,
          borderRadius: BorderRadius.circular(14),
          child: const Center(
            child: Icon(
              Icons.report_problem_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    ),
  );

  // ---------------- Category helpers ----------------
  // These helpers map the ItemCategory to colors, icons and readable names.
  // Adjust the cases to match your actual ItemCategory enum values.

  LinearGradient _getCategoryGradient(ItemCategory category) {
    final c = _getCategoryColor(category);
    return LinearGradient(
      colors: [c.withOpacity(0.95), c.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getCategoryColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return const Color(0xFF2563EB);
      case ItemCategory.documents:
        return const Color(0xFF8B5CF6);
      case ItemCategory.accessories:
        return const Color(0xFF4ADE80);
      case ItemCategory.keys:
        return const Color(0xFFF59E0B);
      case ItemCategory.wallet:
        return const Color(0xFFEF4444);
      case ItemCategory.clothing:
        return const Color(0xFF60A5FA);
      case ItemCategory.other:
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return Icons.devices_rounded;
      case ItemCategory.documents:
        return Icons.description_rounded;
      case ItemCategory.accessories:
        return Icons.watch_rounded;
      case ItemCategory.keys:
        return Icons.vpn_key_rounded;
      case ItemCategory.wallet:
        return Icons.account_balance_wallet_rounded;
      case ItemCategory.clothing:
        return Icons.checkroom_rounded;
      case ItemCategory.other:
        return Icons.inventory_2_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return 'Électronique';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.accessories:
        return 'Accessoires';
      case ItemCategory.keys:
        return 'Clés';
      case ItemCategory.wallet:
        return 'Portefeuille';
      case ItemCategory.clothing:
        return 'Vêtements';
      case ItemCategory.other:
        return 'Autre';
      default:
        return 'Autre';
    }
  }
}
