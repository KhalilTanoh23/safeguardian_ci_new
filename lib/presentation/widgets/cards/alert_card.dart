import 'package:flutter/material.dart';
import 'package:safeguardian_ci_new/data/models/alert.dart';
import 'package:intl/intl.dart';

class AlertCard extends StatelessWidget {
  final EmergencyAlert alert;
  final VoidCallback? onTap;

  const AlertCard({super.key, required this.alert, this.onTap});

  // Reuse a single DateFormat instance
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(alert.timestamp);
    final bucket = _timeBucketFromTimestamp(alert.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusBorderColor(alert.status),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(
              alert.status,
            ).withAlpha((0.15 * 255).round()),
            blurRadius: 16,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusIcon(alert.status),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAlertTitle(alert.status),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E3A8A),
                                  fontSize: 17,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _dateFormat.format(alert.timestamp),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTimeChip(timeAgo, bucket),
                  ],
                ),

                if (alert.message != null && alert.message!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      alert.message!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Localisation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x143B82F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Position GPS',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${alert.location.latitude.toStringAsFixed(6)}, '
                              '${alert.location.longitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Contacts et communauté
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1A8B5CF6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_rounded,
                            size: 16,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${alert.notifiedContacts.length} notifié(s)',
                            style: const TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (alert.communityAlertSent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x4D10B981),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.groups_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'COMMUNAUTÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(AlertStatus status) {
    IconData icon;
    Gradient gradient;

    switch (status) {
      case AlertStatus.pending:
        icon = Icons.access_time_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
        break;
      case AlertStatus.confirmed:
        icon = Icons.check_circle_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        );
        break;
      case AlertStatus.resolved:
        icon = Icons.done_all_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        );
        break;
      case AlertStatus.falseAlarm:
        icon = Icons.error_outline_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
        break;
      case AlertStatus.cancelled:
        icon = Icons.cancel_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        );
        break;
      case AlertStatus.expired:
        icon = Icons.timer_off_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        );
        break;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withAlpha((0.3 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildTimeChip(String timeAgo, _TimeBucket bucket) {
    final gradient = _getTimeGradientFromBucket(bucket);
    final mainColor = _getTimeMainColorFromBucket(bucket);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: mainColor.withAlpha((0.3 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        timeAgo,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _getAlertTitle(AlertStatus status) {
    switch (status) {
      case AlertStatus.pending:
        return 'Alerte en cours';
      case AlertStatus.confirmed:
        return 'Alerte confirmée';
      case AlertStatus.resolved:
        return 'Alerte résolue';
      case AlertStatus.falseAlarm:
        return 'Fausse alerte';
      case AlertStatus.cancelled:
        return 'Alerte annulée';
      case AlertStatus.expired:
        return 'Alerte expirée';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays ~/ 7} sem';
    } else if (difference.inDays < 365) {
      return 'Il y a ${difference.inDays ~/ 30} mois';
    } else {
      return 'Il y a ${difference.inDays ~/ 365} an';
    }
  }

  // Determine a bucket/category from the timestamp rather than parsing the displayed string
  _TimeBucket _timeBucketFromTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return _TimeBucket.instant;
    if (diff.inMinutes < 60) return _TimeBucket.minutes;
    if (diff.inHours < 24) return _TimeBucket.hours;
    if (diff.inDays < 7) return _TimeBucket.days;
    if (diff.inDays < 30) return _TimeBucket.weeks;
    if (diff.inDays < 365) return _TimeBucket.months;
    return _TimeBucket.years;
  }

  Gradient _getTimeGradientFromBucket(_TimeBucket bucket) {
    switch (bucket) {
      case _TimeBucket.instant:
      case _TimeBucket.minutes:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        );
      case _TimeBucket.hours:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        );
    }
  }

  Color _getTimeMainColorFromBucket(_TimeBucket bucket) {
    switch (bucket) {
      case _TimeBucket.instant:
      case _TimeBucket.minutes:
        return const Color(0xFFEF4444);
      case _TimeBucket.hours:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.pending:
        return const Color(0xFFF59E0B);
      case AlertStatus.confirmed:
      case AlertStatus.resolved:
        return const Color(0xFF10B981);
      case AlertStatus.falseAlarm:
        return const Color(0xFFF59E0B);
      case AlertStatus.cancelled:
      case AlertStatus.expired:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBorderColor(AlertStatus status) {
    return _getStatusColor(status).withAlpha((0.3 * 255).round());
  }
}

enum _TimeBucket { instant, minutes, hours, days, weeks, months, years }
