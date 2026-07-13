import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';

/// Screen where users set per-app usage limits and alert preferences.
class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> {
  // Global daily limit in minutes (0 = not set)
  int _dailyLimitMinutes = 120;
  bool _dailyLimitEnabled = true;

  // Alert type: 0 = notification, 1 = alarm, 2 = both
  int _alertType = 0;

  // Per-app limits: packageName → limit in minutes (0 = no limit)
  final Map<String, int> _appLimits = {
    'Digital Wellbeing': 60,
    'Instagram': 30,
  };

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
              const SizedBox(height: 16),
              _buildDailyLimitCard(),
              const SizedBox(height: 16),
              _buildAlertTypeCard(),
              const SizedBox(height: 20),
              _buildAppLimitsHeader(),
              const SizedBox(height: 8),
              ...dummyApps.map((app) => _buildAppLimitTile(app)),
              const SizedBox(height: 24),
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
        'Usage Limits',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  // ─── Daily Screen Time Limit Card ────────────────────────────────

  Widget _buildDailyLimitCard() {
    final hours = _dailyLimitMinutes ~/ 60;
    final mins = _dailyLimitMinutes % 60;
    final limitText = hours > 0
        ? '${hours}h ${mins > 0 ? '${mins}m' : ''}'
        : '${mins}m';
    // Dummy: assume 7h50m = 470m total usage today
    const usedMinutes = 470;
    final progress = _dailyLimitEnabled
        ? (usedMinutes / _dailyLimitMinutes).clamp(0.0, 1.0)
        : 0.0;
    final isOver = usedMinutes > _dailyLimitMinutes && _dailyLimitEnabled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Screen Limit',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      _dailyLimitEnabled ? limitText : 'Not set',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (_dailyLimitEnabled)
                      Text(
                        isOver ? 'Limit exceeded!' : '${(progress * 100).toInt()}% used today',
                        style: TextStyle(
                          color: isOver ? const Color(0xFFFFCDD2) : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _dailyLimitEnabled ? progress : 0,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        isOver ? const Color(0xFFFF8A80) : Colors.white,
                      ),
                    ),
                    Icon(
                      isOver ? Icons.warning_amber_rounded : Icons.timer_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showDailyLimitPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Edit Limit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () =>
                    setState(() => _dailyLimitEnabled = !_dailyLimitEnabled),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _dailyLimitEnabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _dailyLimitEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: _dailyLimitEnabled
                          ? AppTheme.primary
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Alert Type Card ─────────────────────────────────────────────

  Widget _buildAlertTypeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('When limit is reached',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _alertChip(0, Icons.notifications_outlined, 'Notification'),
              const SizedBox(width: 8),
              _alertChip(1, Icons.alarm, 'Alarm'),
              const SizedBox(width: 8),
              _alertChip(2, Icons.notifications_active, 'Both'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertChip(int index, IconData icon, String label) {
    final isSelected = _alertType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _alertType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.scaffoldBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : AppTheme.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Limits Header ───────────────────────────────────────────

  Widget _buildAppLimitsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text('App Limits',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const Spacer(),
          Text(
            '${_appLimits.length} active',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  // ─── Individual App Limit Tile ───────────────────────────────────

  Widget _buildAppLimitTile(DummyAppUsage app) {
    final limitMins = _appLimits[app.appName] ?? 0;
    final hasLimit = limitMins > 0;
    // Parse dummy usage time to minutes for progress
    final usageMins = _parseUsageMinutes(app.usageTime);
    final progress = hasLimit ? (usageMins / limitMins).clamp(0.0, 1.0) : 0.0;
    final isOver = hasLimit && usageMins > limitMins;

    return GestureDetector(
      onTap: () => _showAppLimitSheet(app),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // App icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: app.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(app.iconData, color: app.iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Name + limit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.appName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  if (hasLimit) ...[
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppTheme.textMuted.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(
                          isOver ? AppTheme.red : AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.usageTime} / ${_formatMins(limitMins)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOver ? AppTheme.red : AppTheme.textMuted,
                        fontWeight: isOver ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ] else
                    Text('No limit set',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: hasLimit
                    ? (isOver
                        ? AppTheme.red.withValues(alpha: 0.1)
                        : AppTheme.primary.withValues(alpha: 0.1))
                    : AppTheme.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasLimit
                    ? (isOver ? 'Over' : '${(progress * 100).toInt()}%')
                    : 'Set',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasLimit
                      ? (isOver ? AppTheme.red : AppTheme.primary)
                      : AppTheme.textMuted,
                ),
              ),
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  // ─── Daily Limit Picker ──────────────────────────────────────────

  void _showDailyLimitPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _LimitPickerSheet(
          title: 'Daily Screen Limit',
          currentMinutes: _dailyLimitMinutes,
          presets: const [60, 120, 180, 240, 300],
          onConfirm: (mins) {
            setState(() => _dailyLimitMinutes = mins);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  // ─── Per-App Limit Sheet ─────────────────────────────────────────

  void _showAppLimitSheet(DummyAppUsage app) {
    final current = _appLimits[app.appName] ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _LimitPickerSheet(
          title: 'Limit for ${app.appName}',
          currentMinutes: current,
          presets: const [15, 30, 60, 90, 120],
          showRemove: current > 0,
          onConfirm: (mins) {
            setState(() {
              if (mins > 0) {
                _appLimits[app.appName] = mins;
              } else {
                _appLimits.remove(app.appName);
              }
            });
            Navigator.pop(ctx);
          },
          onRemove: () {
            setState(() => _appLimits.remove(app.appName));
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  int _parseUsageMinutes(String usage) {
    int total = 0;
    final hMatch = RegExp(r'(\d+)h').firstMatch(usage);
    final mMatch = RegExp(r'(\d+)m').firstMatch(usage);
    if (hMatch != null) total += int.parse(hMatch.group(1)!) * 60;
    if (mMatch != null) total += int.parse(mMatch.group(1)!);
    return total;
  }

  String _formatMins(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }
}

// ─── Reusable Limit Picker Bottom Sheet ────────────────────────────────

class _LimitPickerSheet extends StatefulWidget {
  final String title;
  final int currentMinutes;
  final List<int> presets;
  final bool showRemove;
  final ValueChanged<int> onConfirm;
  final VoidCallback? onRemove;

  const _LimitPickerSheet({
    required this.title,
    required this.currentMinutes,
    required this.presets,
    this.showRemove = false,
    required this.onConfirm,
    this.onRemove,
  });

  @override
  State<_LimitPickerSheet> createState() => _LimitPickerSheetState();
}

class _LimitPickerSheetState extends State<_LimitPickerSheet> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes =
        widget.currentMinutes > 0 ? widget.currentMinutes : widget.presets[1];
  }

  String _fmt(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),

          // Selected time display
          Text(
            _fmt(_selectedMinutes),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Preset chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: widget.presets.map((mins) {
                final isSelected = _selectedMinutes == mins;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMinutes = mins),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.scaffoldBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _fmt(mins),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // +/- fine tuning
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _selectedMinutes > 5
                    ? () => setState(() => _selectedMinutes -= 5)
                    : null,
                icon: Icon(Icons.remove_circle_outline,
                    color: _selectedMinutes > 5
                        ? AppTheme.primary
                        : AppTheme.textMuted),
              ),
              Text('± 5 min',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
              IconButton(
                onPressed: () => setState(() => _selectedMinutes += 5),
                icon: Icon(Icons.add_circle_outline,
                    color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Confirm + Remove buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (widget.showRemove) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('Remove',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.red)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onConfirm(_selectedMinutes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Set Limit',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
