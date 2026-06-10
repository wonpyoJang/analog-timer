package dev.analogtimer.analog_timer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dev.analogtimer/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        TimerNotificationManager.createChannel(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateState" -> {
                        val label   = call.argument<String>("timerLabel")  ?: ""
                        val time    = call.argument<String>("timerTime")   ?: "--:--"
                        val swTime  = call.argument<String>("swTime")      ?: ""
                        val active  = call.argument<Boolean>("timerActive") ?: false
                        val colorLong = (call.argument<Any>("timerColor") as? Number)?.toLong()
                            ?: 0xFFE07A52L
                        val color = colorLong.toInt()

                        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                        prefs.edit()
                            .putBoolean("flutter.wgt_timer_active", active)
                            .putString("flutter.wgt_timer_label",  label)
                            .putString("flutter.wgt_timer_time",   time)
                            .putString("flutter.wgt_sw_time",      swTime)
                            .putInt("flutter.wgt_timer_color",     color)
                            .apply()

                        TimerWidgetProvider.updateAllWidgets(this)
                        TimerNotificationManager.update(this, label, time, swTime, active)
                        result.success(null)
                    }
                    "cancelNotification" -> {
                        TimerNotificationManager.cancel(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
