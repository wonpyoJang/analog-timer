package dev.analogtimer.analog_timer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object TimerNotificationManager {
    private const val CHANNEL_ID   = "analog_timer_status"
    private const val NOTIFICATION_ID = 1001

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID, "타이머 상태", NotificationManager.IMPORTANCE_LOW
            ).apply {
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                description = "타이머/스탑워치 진행 상태"
            }
            nm(context).createNotificationChannel(ch)
        }
    }

    fun update(context: Context, label: String, timerTime: String, swTime: String, active: Boolean) {
        if (!active) { cancel(context); return }

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pi = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        val title = if (label.isNotEmpty()) "⏱ $label" else "⏱ ANALOG TIMER"
        val body  = buildString {
            append(timerTime)
            if (swTime.isNotEmpty()) append("   ⏲ $swTime")
        }

        val notif = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_timer_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pi)
            .setOngoing(true)
            .setSilent(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        nm(context).notify(NOTIFICATION_ID, notif)
    }

    fun cancel(context: Context) = nm(context).cancel(NOTIFICATION_ID)

    private const val ALARM_CHANNEL_ID = "analog_timer_alarm"
    private const val TEST_NOTIFICATION_ID = 1002

    /** 알람 점검용 테스트 알람 — 고중요도 채널(소리·진동·헤드업)로 즉시 발송.
     *  사용자가 "알람이 실제로 울리는지" 확인하는 장치(디자인 §F). */
    fun testAlarm(context: Context, title: String, body: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                ALARM_CHANNEL_ID, "타이머 알람", NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                enableVibration(true)
                description = "타이머 완료 알람"
            }
            nm(context).createNotificationChannel(ch)
        }
        val n = NotificationCompat.Builder(context, ALARM_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .build()
        nm(context).notify(TEST_NOTIFICATION_ID, n)
    }

    private fun nm(ctx: Context) =
        ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
}
