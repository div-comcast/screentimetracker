import 'package:flutter/material.dart';
import '../../backend/domains/usage/schema.dart';

class ApplicationsScreen extends StatefulWidget {
  final DailyUsageReport report;

  const ApplicationsScreen({super.key, required this.report});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  int? _expandedIndex;
  String _searchQuery = '';
  bool _showSearch = false;

  // Card background colors cycling
  static const _cardColors = [
    Color(0xFFF5F3F0), // warm white/gray
    Color(0xFFE8F5E2), // light green
    Color(0xFFF5E8E8), // light pink
    Color(0xFFE8EDF5), // light blue
    Color(0xFFFFF3E0), // light orange
  ];

  List<AppDailyRecord> get _filteredApps {
    final apps = widget.report.apps
        .where((a) => a.actualTimeUsed > 0)
        .toList();
    if (_searchQuery.isEmpty) return apps;
    return apps
        .where((a) =>
            a.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: _filteredApps.length,
                itemBuilder: (context, index) {
                  final app = _filteredApps[index];
                  final isExpanded = _expandedIndex == index;
                  final color = _cardColors[index % _cardColors.length];
                  return _AppCard(
                    app: app,
                    color: color,
                    isExpanded: isExpanded,
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          if (_showSearch)
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search apps...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF999999)),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            )
          else
            const Expanded(
              child: Text(
                'Applications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
        ],
      ),
    );
  }
}

// ─── Individual App Card ──────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  final AppDailyRecord app;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  const _AppCard({
    required this.app,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  String get _timePerDay {
    final totalMin = app.actualTimeUsed ~/ 60000;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')} hrs/day';
    return '$m mins/day';
  }

  String get _focusImpact {
    final hours = app.actualTimeUsed / 3600000;
    if (hours >= 2) return 'High focus impact';
    if (hours >= 0.5) return 'Moderate focus impact';
    return 'Low focus impact';
  }

  Color get _focusImpactColor {
    final hours = app.actualTimeUsed / 3600000;
    if (hours >= 2) return const Color(0xFFE87070);
    if (hours >= 0.5) return const Color(0xFFE8A830);
    return const Color(0xFF4CAF50);
  }

  String get _lastActiveStr {
    final diff = DateTime.now().difference(app.lastUsed);
    if (diff.inMinutes < 1) return 'Active now';
    if (diff.inMinutes < 60) return 'Last active ${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return 'Last active ${diff.inHours} hrs ago';
    return 'Last active ${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App header row ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.appName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _timePerDay,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.expand_less_rounded,
                          size: 20,
                          color: Color(0xFF666666),
                        ),
                      ),
                    if (isExpanded) const SizedBox(width: 8),
                    // App icon
                    _buildAppIcon(),
                  ],
                ),

                // ── Expanded details ──────────────────────────────────────
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  // Tags row
                  Row(
                    children: [
                      _tag(_focusImpact, _focusImpactColor),
                      const SizedBox(width: 10),
                      _tag(_lastActiveStr, const Color(0xFF666666)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Session timeline
                  _SessionTimeline(sessions: app.sessions),
                  const SizedBox(height: 18),

                  // Stats row
                  _buildStatsRow(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    if (app.appIcon != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            app.appIcon!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _iconFallback(),
          ),
        ),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFD9CFC2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF777777),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalMin = app.actualTimeUsed ~/ 60000;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    // Average session duration
    final avgMs = app.sessions.isNotEmpty
        ? app.sessions.fold(0, (sum, s) => sum + s.duration) ~/ app.sessions.length
        : 0;
    final avgMin = avgMs ~/ 60000;
    final avgSec = (avgMs % 60000) ~/ 1000;
    final avgStr = avgMin > 0 ? '$avgMin min $avgSec sec' : '$avgSec sec';

    // First session time
    final firstTime = app.sessions.isNotEmpty
        ? _formatTime(app.sessions.first.start)
        : _formatTime(app.firstUsed);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$timeStr today',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${app.sessionCount} pickups',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              firstTime,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE87070),
              ),
            ),
            Text(
              avgStr,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }
}

// ─── Session Timeline Bar Chart ───────────────────────────────────────────────

class _SessionTimeline extends StatelessWidget {
  final List<AppSession> sessions;

  const _SessionTimeline({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Build hourly buckets from 6 AM to 11 PM
    final buckets = List.filled(18, 0); // 6AM to 11PM = 18 hours
    for (final session in sessions) {
      final startHour = session.start.hour;
      final endHour = session.end.hour;
      for (int h = startHour; h <= endHour && h < 24; h++) {
        final bucketIdx = h - 6;
        if (bucketIdx >= 0 && bucketIdx < 18) {
          // Calculate ms contribution to this hour
          final hourStart = DateTime(
            session.start.year,
            session.start.month,
            session.start.day,
            h,
          );
          final hourEnd = hourStart.add(const Duration(hours: 1));
          final overlapStart =
              session.start.isAfter(hourStart) ? session.start : hourStart;
          final overlapEnd =
              session.end.isBefore(hourEnd) ? session.end : hourEnd;
          final ms = overlapEnd.difference(overlapStart).inMilliseconds;
          if (ms > 0) buckets[bucketIdx] += ms;
        }
      }
    }

    final maxVal = buckets.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(18, (i) {
              final fraction =
                  maxVal > 0 ? (buckets[i] / maxVal).clamp(0.0, 1.0) : 0.0;
              final hasActivity = buckets[i] > 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: hasActivity ? (fraction * 44).clamp(4.0, 44.0) : 4,
                        decoration: BoxDecoration(
                          color: hasActivity
                              ? const Color(0xFFE87070)
                              : const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Dot for inactive
                      if (!hasActivity) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        // Hour labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _hourLabel('8 AM'),
            _hourLabel('10 AM'),
            _hourLabel('12 PM'),
            _hourLabel('2 PM'),
            _hourLabel('4 PM'),
            _hourLabel('6 PM'),
            _hourLabel('8 PM'),
          ],
        ),
      ],
    );
  }

  Widget _hourLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF999999),
      ),
    );
  }
}
