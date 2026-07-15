import 'package:flutter/material.dart';
import '../../../backend/domains/usage/reports.dart';
import '../../../backend/domains/usage/schema.dart';
import '../../theme/app_theme.dart';

class AppUsageSection extends StatefulWidget {
  final DateTime start;
  final DateTime end;

  const AppUsageSection({super.key, required this.start, required this.end});

  @override
  State<AppUsageSection> createState() => _AppUsageSectionState();
}

class _AppUsageSectionState extends State<AppUsageSection> {
  AppSortOrder _sortOrder = AppSortOrder.byTime;
  Future<DailyUsageReport>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AppUsageSection old) {
    super.didUpdateWidget(old);
    if (old.start != widget.start || old.end != widget.end) _load();
  }

  void _load() {
    setState(() {
      _future = getDailyUsageReport(
        startDate: widget.start,
        endDate: widget.end,
        sortOrder: _sortOrder,
      );
    });
  }

  void _onSortChange(AppSortOrder order) {
    if (_sortOrder == order) return;
    setState(() => _sortOrder = order);
    _load();
  }

  static String _fmtMs(int ms) {
    final total = ms ~/ 60000;
    final h = total ~/ 60;
    final m = total % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 4),
          FutureBuilder<DailyUsageReport>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              }
              final apps = snap.data?.apps ?? [];
              if (apps.isEmpty) return _buildEmpty();
              return Column(
                children: apps
                    .map((app) => _AppRow(app: app, fmtMs: _fmtMs))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Header row ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'APP USAGE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        PopupMenuButton<AppSortOrder>(
          onSelected: _onSortChange,
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          offset: const Offset(0, 28),
          itemBuilder: (_) => [
            _sortMenuItem(AppSortOrder.byTime, 'By time'),
            _sortMenuItem(AppSortOrder.bySessions, 'By visits'),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _sortOrder == AppSortOrder.byTime ? 'By time' : 'By visits',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<AppSortOrder> _sortMenuItem(AppSortOrder order, String label) {
    final active = _sortOrder == order;
    return PopupMenuItem(
      value: order,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (active)
            const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Column(
      children: List.generate(4, (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No app usage data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Single app row ───────────────────────────────────────────────────────────

class _AppRow extends StatelessWidget {
  final AppDailyRecord app;
  final String Function(int) fmtMs;

  static const _fallbackColors = [
    Color(0xFFE8553E),
    Color(0xFFE8403B),
    Color(0xFF3D8EF8),
    Color(0xFF25D366),
    Color(0xFF1DB954),
    Color(0xFF6C63FF),
    Color(0xFFFFA500),
    Color(0xFF000000),
  ];

  const _AppRow({required this.app, required this.fmtMs});

  Color get _iconBg =>
      _fallbackColors[app.appName.hashCode.abs() % _fallbackColors.length];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row + time + chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        app.appName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fmtMs(app.actualTimeUsed),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  app.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress bar
                LayoutBuilder(builder: (_, c) {
                  return Stack(
                    children: [
                      Container(
                        height: 4,
                        width: c.maxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        height: 4,
                        width: c.maxWidth *
                            (app.usagePercentage / 100).clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (app.appIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          app.appIcon!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _iconBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
