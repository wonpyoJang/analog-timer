package dev.analogtimer.analog_timer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class TimerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        ids.forEach { updateWidget(context, mgr, it) }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, TimerWidgetProvider::class.java))
            ids.forEach { updateWidget(context, mgr, it) }
        }

        fun updateWidget(context: Context, mgr: AppWidgetManager, id: Int) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val timerActive = prefs.getBoolean("flutter.wgt_timer_active", false)
            val timerLabel  = prefs.getString("flutter.wgt_timer_label", "") ?: ""
            val timerTime   = prefs.getString("flutter.wgt_timer_time",  "--:--") ?: "--:--"
            val timerColor  = prefs.getInt("flutter.wgt_timer_color", 0xFFE07A52.toInt())
            val swTime      = prefs.getString("flutter.wgt_sw_time", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.timer_widget)

            val label = if (timerActive && timerLabel.isNotEmpty()) timerLabel else "ANALOG TIMER"
            views.setTextViewText(R.id.widget_timer_label, label)
            views.setTextViewText(R.id.widget_timer_time, if (timerActive) timerTime else "--:--")
            views.setTextColor(R.id.widget_timer_time, if (timerActive) timerColor else 0xFF888888.toInt())
            views.setTextViewText(R.id.widget_sw_time, if (swTime.isNotEmpty()) "⏱ $swTime" else "")

            val intent = Intent(context, MainActivity::class.java)
            val pi = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.widget_root, pi)

            mgr.updateAppWidget(id, views)
        }
    }
}
