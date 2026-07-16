import 'package:flutter/material.dart';
import '../../backend/domains/usage/schema.dart';

class FocusScoreCard extends StatelessWidget {
  final DailyUsageReport? report;

  const FocusScoreCard({super.key, this.report});

  // ── Score heuristic: less screen time = higher score ──────────────────────
  double get _score {
    final hours = (report?.kpi.derivedTimeUsed ?? 0) / 3600000;
    final raw = 10.0 - (hours * 1.5).clamp(0.0, 9.0);
    // Round to nearest 0.5
    return (raw * 2).round() / 2;
  }

  String get _scoreLabel {
    if (_score >= 7.5) return 'Good';
    if (_score >= 5.0) return 'Fair';
    return 'Needs Work';
  }

  String get _insightMessage {
    final pct = report?.kpi.vsYesterdayPct;
    if (pct == null) {
      return 'Keep going! Stay mindful of your screen time today.';
    }
    final abs = pct.abs().toStringAsFixed(0);
    if (pct < 0) {
      return 'Way to go! Your screen time today\nis $abs% less than yesterday';
    }
    return 'Your screen time today is $abs% more\nthan yesterday. Try to cut back!';
  }

  /// Top apps with icons (max 5, icon must be non-null)
  List<AppDailyRecord> get _topApps {
    final apps = report?.apps ?? [];
    return apps.where((a) => a.appIcon != null).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFD0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──────────────────────────────────────────────────────
          const Text(
            'FOCUS SCORE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B7050),
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // ── Score + Most-used apps ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score number + star
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _score.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFE87070),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scoreLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Most-used app icons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _topApps.isEmpty
                      ? const SizedBox(height: 40)
                      : _AppIconStack(apps: _topApps),
                  const SizedBox(height: 5),
                  const Text(
                    'Most used',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            color: const Color(0xFF8B7050).withValues(alpha: 0.18),
            height: 1,
          ),
          const SizedBox(height: 14),

          // ── Insight row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _insightMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3A3A3A),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Overlapping circular app icon stack ──────────────────────────────────────

class _AppIconStack extends StatelessWidget {
  final List<AppDailyRecord> apps;
  static const double _size = 38.0;
  static const double _overlap = 14.0;

  const _AppIconStack({required this.apps});

  @override
  Widget build(BuildContext context) {
    final total = _size + (apps.length - 1) * (_size - _overlap);
    return SizedBox(
      width: total,
      height: _size,
      child: Stack(
        children: [
          for (int i = 0; i < apps.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: GestureDetector(
                onTap: () => _showAppDetail(context, apps[i]),
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFBEFD0),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.memory(
                      apps[i].appIcon!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(apps[i].appName),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(String name) => Container(
        color: const Color(0xFFD9CFC2),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF777777),
            ),
          ),
        ),
      );

  void _showAppDetail(BuildContext context, AppDailyRecord app) {
    final totalMin = app.actualTimeUsed ~/ 60000;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Icon + name
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    app.appIcon!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        app.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: [
                _statTile('Screen time', timeStr),
                const SizedBox(width: 12),
                _statTile('Sessions', '${app.sessionCount}'),
                const SizedBox(width: 12),
                _statTile('Share', '${app.usagePercentage.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2EDE4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      );
}
