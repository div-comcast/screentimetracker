import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

/// Session details screen shown when a user taps an app tile.
class SessionsScreen extends StatelessWidget {
  final DummyAppUsage app;

  const SessionsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    // Generate dummy session data based on the app's session count
    final sessions = _generateDummySessions(app.sessions);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Session details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── App Header ───────────────────────────────────────
            _buildAppHeader(),

            const SizedBox(height: 20),

            // ── Stats Row ────────────────────────────────────────
            _buildStatsRow(),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── Date / First / Last used ─────────────────────────
            _buildDateInfoRow(sessions),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── Sessions Header ──────────────────────────────────
            _buildSessionsHeader(),

            const SizedBox(height: 8),

            // ── Session List ─────────────────────────────────────
            ...sessions.asMap().entries.map(
                  (entry) => _buildSessionTile(entry.key + 1, entry.value),
                ),

            const SizedBox(height: 12),

            // ── Footer note ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'All times are on Jul 10, 2026',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── App Header: icon, name, package, category chip ────────────────

  Widget _buildAppHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: app.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(app.iconData, color: app.iconColor, size: 30),
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
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'com.example.${app.appName.toLowerCase().replaceAll(' ', '')}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              app.category,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats: Total time, Usage %, Sessions ─────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statItem(Icons.access_time, 'Total time', app.usageTime, AppTheme.primary),
          const SizedBox(width: 16),
          _statItem(Icons.pie_chart_outline, 'Usage', '${app.usagePercent}%', AppTheme.textSecondary),
          const SizedBox(width: 16),
          _statItem(Icons.sensors, 'Sessions', '${app.sessions}', AppTheme.primary),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppTheme.textMuted),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date / First used / Last used ────────────────────────────────

  Widget _buildDateInfoRow(List<_DummySession> sessions) {
    final firstUsed = sessions.isNotEmpty ? sessions.first.startTime : '--:--:--';
    final lastUsed = sessions.isNotEmpty ? sessions.last.endTime : '--:--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _infoChip(Icons.calendar_month, 'Date', 'Fri, Jul 10, 2026', AppTheme.primary),
          const SizedBox(width: 12),
          _infoChip(Icons.wb_sunny_outlined, 'First used', firstUsed, AppTheme.green),
          const SizedBox(width: 12),
          _infoChip(Icons.nights_stay_outlined, 'Last used', lastUsed, AppTheme.red),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color iconColor) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Sessions list header ─────────────────────────────────────────

  Widget _buildSessionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.equalizer, size: 20, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            'Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const Spacer(),
          Text(
            '${app.sessions} sessions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Individual session tile ──────────────────────────────────────

  Widget _buildSessionTile(int index, _DummySession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Session dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Start time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.startTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jul 10, 2026',
                style: AppTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(width: 16),
          Icon(Icons.arrow_forward, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 16),

          // End time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.endTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jul 10, 2026',
                style: AppTheme.bodySmall,
              ),
            ],
          ),

          const Spacer(),

          // Duration
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(
                session.duration,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  // ─── Generate dummy sessions ──────────────────────────────────────

  List<_DummySession> _generateDummySessions(int count) {
    final baseSessions = <_DummySession>[
      _DummySession('09:41:38', '09:46:45', '5m 6s'),
      _DummySession('13:26:38', '13:53:11', '26m 32s'),
      _DummySession('13:57:07', '13:58:27', '1m 19s'),
      _DummySession('14:26:35', '14:28:32', '1m 57s'),
      _DummySession('15:04:07', '15:04:31', '23s'),
      _DummySession('15:04:47', '15:07:15', '2m 27s'),
      _DummySession('15:20:44', '15:22:39', '1m 55s'),
      _DummySession('15:24:57', '15:25:45', '47s'),
      _DummySession('15:34:05', '15:40:36', '6m 31s'),
      _DummySession('16:08:44', '16:20:30', '11m 46s'),
      _DummySession('16:34:25', '16:34:27', '1s'),
      _DummySession('16:35:32', '16:35:48', '16s'),
    ];

    // Return up to the requested count, cycling if needed
    final result = <_DummySession>[];
    for (int i = 0; i < count && i < baseSessions.length; i++) {
      result.add(baseSessions[i]);
    }
    return result;
  }
}

class _DummySession {
  final String startTime;
  final String endTime;
  final String duration;

  _DummySession(this.startTime, this.endTime, this.duration);
}
