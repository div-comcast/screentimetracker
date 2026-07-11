package com.example.screentimetracker

data class AppUsageRecord(
    val packageName: String,
    val appName: String,
    val date: String,
    val totalForegroundTimeMs: Long,
    val firstTimeUsed: Long,
    val lastTimeUsed: Long,
    val androidCategory: String,
)

data class AppIcon(
    val packageName: String,
    val appName: String,
    val iconBytes: ByteArray?
)

data class UsageEventRecord(
    val packageName: String,
    val appName: String,
    val eventType: String, // one of the EventType constants below
    val timestamp: Long
) {
    companion object EventType {
        const val FOREGROUND = "FOREGROUND" // ACTIVITY_RESUMED  — app came to screen
        const val BACKGROUND = "BACKGROUND" // ACTIVITY_PAUSED   — app left screen
        const val SCREEN_ON  = "SCREEN_ON"  // SCREEN_INTERACTIVE        — display turned on
        const val SCREEN_OFF = "SCREEN_OFF" // SCREEN_NON_INTERACTIVE    — display turned off
    }
}
