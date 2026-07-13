import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimelineTile extends StatelessWidget {
  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // ── Time label (left) ──────────────────────────────
            SizedBox(
              width: 62,
              child: Text(
                entry.timeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // ── App icon ───────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.appColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(entry.iconData, color: entry.appColor, size: 20),
            ),
            const SizedBox(width: 4),

            // ── Timeline line + dot ────────────────────────────
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  // Line above dot
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isFirst
                          ? Colors.transparent
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                  // Dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: entry.appColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Line below dot
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast
                          ? Colors.transparent
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── App info ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.appName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.startTime} – ${entry.endTime}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // ── Duration ───────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: entry.appColor),
                const SizedBox(width: 4),
                Text(
                  entry.duration,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: entry.appColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────

class TimelineEntry {
  final String timeLabel;
  final String appName;
  final IconData iconData;
  final Color appColor;
  final String startTime;
  final String endTime;
  final String duration;

  const TimelineEntry({
    required this.timeLabel,
    required this.appName,
    required this.iconData,
    required this.appColor,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}

// ─── Dummy timeline data ─────────────────────────────────────────────────

const dummyTimelineEntries = [
  TimelineEntry(
    timeLabel: '03:27 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '03:27:18',
    endTime: '03:27:34',
    duration: '15s',
  ),
  TimelineEntry(
    timeLabel: '07:55 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '07:55:02',
    endTime: '07:55:06',
    duration: '3s',
  ),
  TimelineEntry(
    timeLabel: '07:55 AM',
    appName: 'Cleaner',
    iconData: Icons.cleaning_services,
    appColor: Color(0xFFF47521),
    startTime: '07:55:06',
    endTime: '07:55:20',
    duration: '14s',
  ),
  TimelineEntry(
    timeLabel: '07:55 AM',
    appName: 'LinkedIn',
    iconData: Icons.work,
    appColor: Color(0xFF0077B5),
    startTime: '07:55:28',
    endTime: '07:55:47',
    duration: '19s',
  ),
  TimelineEntry(
    timeLabel: '07:59 AM',
    appName: 'LinkedIn',
    iconData: Icons.work,
    appColor: Color(0xFF0077B5),
    startTime: '07:59:15',
    endTime: '07:59:22',
    duration: '6s',
  ),
  TimelineEntry(
    timeLabel: '07:59 AM',
    appName: 'Instagram',
    iconData: Icons.camera_alt,
    appColor: Color(0xFFE1306C),
    startTime: '07:59:23',
    endTime: '08:01:29',
    duration: '2m 5s',
  ),
  TimelineEntry(
    timeLabel: '08:03 AM',
    appName: 'Calculator',
    iconData: Icons.calculate,
    appColor: Color(0xFF757575),
    startTime: '08:03:43',
    endTime: '08:04:26',
    duration: '42s',
  ),
  TimelineEntry(
    timeLabel: '08:04 AM',
    appName: 'Instagram',
    iconData: Icons.camera_alt,
    appColor: Color(0xFFE1306C),
    startTime: '08:04:27',
    endTime: '08:08:34',
    duration: '4m 6s',
  ),
  TimelineEntry(
    timeLabel: '08:11 AM',
    appName: 'Instagram',
    iconData: Icons.camera_alt,
    appColor: Color(0xFFE1306C),
    startTime: '08:11:02',
    endTime: '08:15:56',
    duration: '4m 53s',
  ),
  TimelineEntry(
    timeLabel: '08:15 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:15:58',
    endTime: '08:16:05',
    duration: '6s',
  ),
  TimelineEntry(
    timeLabel: '08:16 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:16:05',
    endTime: '08:16:05',
    duration: '0s',
  ),
  TimelineEntry(
    timeLabel: '08:16 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:16:05',
    endTime: '08:16:11',
    duration: '6s',
  ),
  TimelineEntry(
    timeLabel: '08:16 AM',
    appName: 'Instagram',
    iconData: Icons.camera_alt,
    appColor: Color(0xFFE1306C),
    startTime: '08:16:11',
    endTime: '08:42:54',
    duration: '26m 42s',
  ),
  TimelineEntry(
    timeLabel: '08:42 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:42:55',
    endTime: '08:43:02',
    duration: '7s',
  ),
  TimelineEntry(
    timeLabel: '08:43 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:43:02',
    endTime: '08:43:02',
    duration: '0s',
  ),
  TimelineEntry(
    timeLabel: '08:43 AM',
    appName: 'Chrome',
    iconData: Icons.language,
    appColor: Color(0xFF4285F4),
    startTime: '08:43:02',
    endTime: '08:43:46',
    duration: '43s',
  ),
  TimelineEntry(
    timeLabel: '08:43 AM',
    appName: 'Google Play services',
    iconData: Icons.stars,
    appColor: Color(0xFF4CAF50),
    startTime: '08:43:46',
    endTime: '08:43:48',
    duration: '2s',
  ),
  TimelineEntry(
    timeLabel: '08:43 AM',
    appName: 'Google',
    iconData: Icons.search,
    appColor: Color(0xFFFBBC05),
    startTime: '08:43:48',
    endTime: '08:43:49',
    duration: '0s',
  ),
];
