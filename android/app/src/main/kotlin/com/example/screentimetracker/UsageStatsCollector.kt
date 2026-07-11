package com.example.screentimetracker

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import java.text.SimpleDateFormat
import java.util.*

class UsageStatsCollector(private val context: Context) {

    private val usageStatsManager =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    private val packageManager = context.packageManager

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())

    private fun getAppName(packageName: String): String {
        return try {
            val info = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName
        }
    }

    private fun getAndroidCategory(packageName: String): String {
        return try {
            val info = packageManager.getApplicationInfo(packageName, 0)
            when (info.category) {
                ApplicationInfo.CATEGORY_GAME        -> "Games"
                ApplicationInfo.CATEGORY_AUDIO       -> "Audio"
                ApplicationInfo.CATEGORY_VIDEO       -> "Videos"
                ApplicationInfo.CATEGORY_IMAGE       -> "Photos"
                ApplicationInfo.CATEGORY_SOCIAL      -> "Social"
                ApplicationInfo.CATEGORY_NEWS        -> "News"
                ApplicationInfo.CATEGORY_MAPS        -> "Maps"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "Productivity"
                else                                 -> "Other"
            }
        } catch (e: PackageManager.NameNotFoundException) {
            "Other"
        }
    }

    fun getLauncherPackages(): List<String> {
        val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        return packageManager.queryIntentActivities(homeIntent, PackageManager.MATCH_DEFAULT_ONLY)
            .map { it.activityInfo.packageName }
            .distinct()
    }

    fun collectDailyAppUsage(date: Calendar = Calendar.getInstance()): List<AppUsageRecord> {
        val startOfDay = date.clone() as Calendar
        startOfDay.set(Calendar.HOUR_OF_DAY, 0)
        startOfDay.set(Calendar.MINUTE, 0)
        startOfDay.set(Calendar.SECOND, 0)
        startOfDay.set(Calendar.MILLISECOND, 0)

        val endOfDay = startOfDay.clone() as Calendar
        endOfDay.set(Calendar.HOUR_OF_DAY, 23)
        endOfDay.set(Calendar.MINUTE, 59)
        endOfDay.set(Calendar.SECOND, 59)

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startOfDay.timeInMillis,
            endOfDay.timeInMillis
        )

        val boundaries = appEventBoundaries(startOfDay.timeInMillis, endOfDay.timeInMillis)

        val dateStr = dateFormat.format(startOfDay.time)

        return stats
            .filter { (boundaries.totalForegroundMs[it.packageName] ?: 0L) > 0 }
            .map {
                val pkg = it.packageName
                AppUsageRecord(
                    packageName = pkg,
                    appName = getAppName(pkg),
                    totalForegroundTimeMs = boundaries.totalForegroundMs[pkg] ?: 0L,
                    firstTimeUsed = boundaries.firstForeground[pkg] ?: startOfDay.timeInMillis,
                    lastTimeUsed = boundaries.lastBackground[pkg] ?: it.lastTimeStamp,
                    date = dateStr,
                    androidCategory = getAndroidCategory(pkg),
                )
            }
            .sortedByDescending { it.totalForegroundTimeMs }
    }

    data class AppEventBoundaries(
        val firstForeground: Map<String, Long>,
        val lastBackground: Map<String, Long>,
        val totalForegroundMs: Map<String, Long>,
    )

    private fun appEventBoundaries(startMs: Long, endMs: Long): AppEventBoundaries {
        val events = usageStatsManager.queryEvents(startMs, endMs)
        val event = UsageEvents.Event()
        val firstForeground = mutableMapOf<String, Long>()
        val lastBackground = mutableMapOf<String, Long>()
        val totalForegroundMs = mutableMapOf<String, Long>()
        val foregroundStart = mutableMapOf<String, Long>()
        // Track physical screen state so that time while the screen is off is never counted.
        // SCREEN_NON_INTERACTIVE (16) / SCREEN_INTERACTIVE (15) — available from API 23.
        // On API 21-22 these events are simply absent; the logic degrades gracefully.
        var screenOn = true

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName
            val ts = event.timeStamp
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    // Only open an on-screen session when the display is actually on.
                    if (screenOn) {
                        firstForeground.putIfAbsent(pkg, ts)
                        foregroundStart[pkg] = ts
                    }
                }
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    lastBackground[pkg] = ts
                    val start = foregroundStart.remove(pkg)
                    if (start != null) {
                        totalForegroundMs[pkg] = (totalForegroundMs[pkg] ?: 0L) + (ts - start)
                    }
                }
                // SCREEN_NON_INTERACTIVE = 16
                // Safety flush: close every open session at the exact moment the screen goes off.
                // On most devices ACTIVITY_PAUSED fires first, making foregroundStart already empty,
                // but some OEM ROMs skip PAUSED on screen-off so this acts as the authoritative gate.
                16 -> {
                    screenOn = false
                    for ((p, start) in foregroundStart) {
                        val duration = ts - start
                        if (duration > 0) {
                            totalForegroundMs[p] = (totalForegroundMs[p] ?: 0L) + duration
                            lastBackground[p] = ts
                        }
                    }
                    foregroundStart.clear()
                }
                // SCREEN_INTERACTIVE = 15
                // Screen is on again; ACTIVITY_RESUMED events will follow for the active app.
                15 -> screenOn = true
            }
        }

        // App still on screen at end of window — close the open session only when screen is on.
        if (screenOn) {
            val windowEnd = minOf(endMs, System.currentTimeMillis())
            for ((pkg, start) in foregroundStart) {
                val duration = windowEnd - start
                if (duration > 0) totalForegroundMs[pkg] = (totalForegroundMs[pkg] ?: 0L) + duration
            }
        }

        return AppEventBoundaries(firstForeground, lastBackground, totalForegroundMs)
    }

    fun collectUsageEvents(
        startTimeMs: Long,
        endTimeMs: Long
    ): List<UsageEventRecord> {
        val events = usageStatsManager.queryEvents(startTimeMs, endTimeMs)
        val result = mutableListOf<UsageEventRecord>()
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)

            val type = when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> UsageEventRecord.FOREGROUND
                UsageEvents.Event.ACTIVITY_PAUSED  -> UsageEventRecord.BACKGROUND
                15 -> UsageEventRecord.SCREEN_ON   // SCREEN_INTERACTIVE
                16 -> UsageEventRecord.SCREEN_OFF  // SCREEN_NON_INTERACTIVE
                else -> continue
            }

            result.add(
                UsageEventRecord(
                    packageName = event.packageName,
                    appName = getAppName(event.packageName),
                    eventType = type,
                    timestamp = event.timeStamp
                )
            )
        }

        return result
    }

    fun collectRangeAppUsage(startTimeMs: Long, endTimeMs: Long): List<AppUsageRecord> {
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTimeMs,
            endTimeMs
        )

        val boundaries = appEventBoundaries(startTimeMs, endTimeMs)
        val dateStr = dateFormat.format(Date(startTimeMs))

        return stats
            .filter { (boundaries.totalForegroundMs[it.packageName] ?: 0L) > 0 }
            .map {
                val pkg = it.packageName
                AppUsageRecord(
                    packageName = pkg,
                    appName = getAppName(pkg),
                    totalForegroundTimeMs = boundaries.totalForegroundMs[pkg] ?: 0L,
                    firstTimeUsed = boundaries.firstForeground[pkg] ?: startTimeMs,
                    lastTimeUsed = boundaries.lastBackground[pkg] ?: it.lastTimeStamp,
                    date = dateStr,
                    androidCategory = getAndroidCategory(pkg),
                )
            }
            .sortedByDescending { it.totalForegroundTimeMs }
    }
}
