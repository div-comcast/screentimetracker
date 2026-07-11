package com.example.screentimetracker

import android.app.AppOpsManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val channel = "com.example.screentimetracker/usage"

    private lateinit var usageStatsCollector: UsageStatsCollector
    private lateinit var appIconProvider: AppIconProvider

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        usageStatsCollector = UsageStatsCollector(this)
        appIconProvider = AppIconProvider(packageManager)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "hasUsagePermission" -> {
                        result.success(hasUsagePermission())
                    }

                    "requestUsagePermission" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }

                    "getDailyAppUsage" -> {
                        if (!hasUsagePermission()) {
                            result.error("NO_PERMISSION", "Usage stats permission not granted", null)
                            return@setMethodCallHandler
                        }
                        val records = usageStatsCollector.collectDailyAppUsage()
                        result.success(records.map { it.toMap() })
                    }

                    "getAppUsageForDate" -> {
                        if (!hasUsagePermission()) {
                            result.error("NO_PERMISSION", "Usage stats permission not granted", null)
                            return@setMethodCallHandler
                        }
                        val dateMs = call.argument<Long>("dateMs") ?: System.currentTimeMillis()
                        val cal = Calendar.getInstance().apply { timeInMillis = dateMs }
                        val records = usageStatsCollector.collectDailyAppUsage(cal)
                        result.success(records.map { it.toMap() })
                    }

                    "getUsageEvents" -> {
                        if (!hasUsagePermission()) {
                            result.error("NO_PERMISSION", "Usage stats permission not granted", null)
                            return@setMethodCallHandler
                        }
                        val startMs = call.argument<Long>("startMs") ?: return@setMethodCallHandler
                        val endMs = call.argument<Long>("endMs") ?: return@setMethodCallHandler
                        val events = usageStatsCollector.collectUsageEvents(startMs, endMs)
                        result.success(events.map { it.toMap() })
                    }

                    "getLauncherPackages" -> {
                        result.success(usageStatsCollector.getLauncherPackages())
                    }

                    "getAppIcons" -> {
                        val packageNames = call.argument<List<String>>("packageNames")
                            ?: return@setMethodCallHandler result.error("BAD_ARGS", "packageNames required", null)
                        val icons = appIconProvider.getIconsForPackages(packageNames)
                        result.success(icons.map { it.toMap() })
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}

fun AppUsageRecord.toMap(): Map<String, Any> = mapOf(
    "packageName" to packageName,
    "appName" to appName,
    "totalForegroundTimeMs" to totalForegroundTimeMs,
    "firstTimeUsed" to firstTimeUsed,
    "lastTimeUsed" to lastTimeUsed,
    "date" to date,
    "androidCategory" to androidCategory,
)

fun AppIcon.toMap(): Map<String, Any?> = mapOf(
    "packageName" to packageName,
    "appName" to appName,
    "iconBytes" to iconBytes
)

fun UsageEventRecord.toMap(): Map<String, Any> = mapOf(
    "packageName" to packageName,
    "appName" to appName,
    "eventType" to eventType,
    "timestamp" to timestamp
)
