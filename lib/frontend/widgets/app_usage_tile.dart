import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

/// A single app row in the usage list: rank, icon, name, category,
/// time range, session count, usage bar, time and percentage.
class AppUsageTile extends StatelessWidget {
  final DummyAppUsage app;
  final VoidCallback? onTap;

  const AppUsageTile({super.key, required this.app, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.tileDecoration,
        child: Row(
          children: [
            // ── Rank ────────────────────────────────────────────
            SizedBox(
              width: 24,
              child: Text(
                '${app.rank}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),

            // ── App Icon ────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: app.iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(app.iconData, color: app.iconColor, size: 24),
            ),
            const SizedBox(width: 12),

            // ── Name / Category / Meta ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: AppTheme.labelBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: app.iconColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: app.usagePercent / 100,
                      minHeight: 4,
                      backgroundColor: app.iconColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(app.iconColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        app.timeRange,
                        style: AppTheme.bodySmall.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${app.sessions} sessions',
                        style: AppTheme.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Usage Time & Percent ────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  app.usageTime,
                  style: AppTheme.labelBold.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.usagePercent}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: app.iconColor,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
