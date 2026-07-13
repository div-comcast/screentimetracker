import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';

/// Focus mode screen — start focus sessions, manage profiles, view stats.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isFocusActive = false;
  int _selectedDuration = 25; // minutes
  int _selectedProfileIndex = 0;

  static const _durations = [15, 25, 45, 60, 90, 120];

  final _profiles = [
    _FocusProfile(
      name: 'Work',
      icon: Icons.work_outline,
      color: AppTheme.primary,
      blockedApps: ['Instagram', 'YouTube', 'Crunchyroll', 'WhatsApp'],
    ),
    _FocusProfile(
      name: 'Study',
      icon: Icons.school_outlined,
      color: Color(0xFF4CAF50),
      blockedApps: ['Instagram', 'YouTube', 'Crunchyroll', 'WhatsApp', 'Chrome'],
    ),
    _FocusProfile(
      name: 'Sleep',
      icon: Icons.nightlight_outlined,
      color: Color(0xFF7C4DFF),
      blockedApps: ['Instagram', 'YouTube', 'Crunchyroll', 'WhatsApp', 'Chrome', 'screentimetracker'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFocusButton(),
              const SizedBox(height: 24),
              _buildDurationSelector(),
              const SizedBox(height: 24),
              _buildProfiles(),
              const SizedBox(height: 24),
              _buildStats(),
              const SizedBox(height: 24),
              _buildBlockedAppsPreview(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'Focus Mode',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  // ─── Big Start/Stop Focus Button ─────────────────────────────────

  Widget _buildFocusButton() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isFocusActive = !_isFocusActive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isFocusActive ? AppTheme.primary : Colors.white,
            boxShadow: [
              BoxShadow(
                color: _isFocusActive
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: _isFocusActive ? 30 : 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFocusActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 48,
                color: _isFocusActive ? Colors.white : AppTheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                _isFocusActive ? 'Stop' : 'Start Focus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isFocusActive ? Colors.white : AppTheme.primary,
                ),
              ),
              if (_isFocusActive) ...[
                const SizedBox(height: 4),
                Text(
                  '$_selectedDuration min',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Duration Selector ───────────────────────────────────────────

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Duration',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _durations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final mins = _durations[index];
              final isSelected = mins == _selectedDuration;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = mins),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected
                        ? null
                        : Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatDuration(mins),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Focus Profiles ──────────────────────────────────────────────

  Widget _buildProfiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Profiles',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _profiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              final isSelected = index == _selectedProfileIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedProfileIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 110,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? profile.color.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? profile.color
                          : AppTheme.textMuted.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(profile.icon, size: 28, color: profile.color),
                      const SizedBox(height: 8),
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? profile.color
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.blockedApps.length} blocked',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Focus Stats ─────────────────────────────────────────────────

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _statItem(Icons.check_circle_outline, 'Today', '3 sessions', AppTheme.primary),
          Container(width: 1, height: 36, color: AppTheme.textMuted.withValues(alpha: 0.15)),
          _statItem(Icons.access_time, 'Focused', '2h 15m', AppTheme.green),
          Container(width: 1, height: 36, color: AppTheme.textMuted.withValues(alpha: 0.15)),
          _statItem(Icons.local_fire_department_outlined, 'Streak', '5 days', AppTheme.orange),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  // ─── Blocked Apps Preview ────────────────────────────────────────

  Widget _buildBlockedAppsPreview() {
    final profile = _profiles[_selectedProfileIndex];
    final blockedDummyApps = dummyApps
        .where((a) => profile.blockedApps.contains(a.appName))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Blocked in "${profile.name}"',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Text('${profile.blockedApps.length} apps',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...blockedDummyApps.map((app) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: app.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(app.iconData, color: app.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(app.appName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  Icon(Icons.block, size: 18, color: AppTheme.red.withValues(alpha: 0.6)),
                ],
              ),
            )),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  String _formatDuration(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }
}

class _FocusProfile {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> blockedApps;

  _FocusProfile({
    required this.name,
    required this.icon,
    required this.color,
    required this.blockedApps,
  });
}
