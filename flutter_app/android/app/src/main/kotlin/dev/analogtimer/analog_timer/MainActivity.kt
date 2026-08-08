package dev.analogtimer.analog_timer

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dev.analogtimer/widget"
    private val MULTI_OVERLAY_CHANNEL = "dev.analogtimer/multi_overlay"
    private val ANR_VITALS_CHANNEL = "dev.analogtimer/anr_vitals"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        TimerNotificationManager.createChannel(this)
        configureMultiOverlayChannel(flutterEngine)
        configureAnrVitalsChannel(flutterEngine)

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

    /** 엔진 없는 네이티브 멀티 오버레이 브리지 — [MultiOverlayService] 로 명령을 startService 전달. */
    private fun configureMultiOverlayChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MULTI_OVERLAY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "show", "update" -> {
                        val id = call.argument<String>("id")
                        val name = call.argument<String>("name") ?: ""
                        val time = call.argument<String>("time") ?: "--:--"
                        val color = (call.argument<Any>("color") as? Number)?.toInt()
                            ?: MultiOverlayService.DEFAULT_ACCENT
                        val frac = (call.argument<Any>("frac") as? Number)?.toFloat() ?: 1f
                        val done = call.argument<Boolean>("done") ?: false
                        val svc = MultiOverlayService.instance
                        if (svc != null && id != null) {
                            // 서비스 기동 상태 — Intent 스로틀을 피해 직접 갱신(부드러운 초 단위).
                            svc.showOrUpdate(id, name, time, color, frac, done)
                        } else {
                            // 콜드 스타트(첫 표시) — Intent 로 서비스 시작.
                            // startForegroundService 대신 startService 를 쓴다: 토글은 항상 앱이
                            // 포그라운드일 때 일어나므로 startService 가 허용되고, 서비스는
                            // onCreate 에서 startForeground 로 승격한다. 이러면 "5초 내 startForeground
                            // 미호출" ANR(ForegroundServiceDidNotStartInTimeException) 자체가 없다.
                            val intent = Intent(this, MultiOverlayService::class.java).apply {
                                putExtra(MultiOverlayService.EXTRA_CMD, MultiOverlayService.CMD_SHOW)
                                putExtra(MultiOverlayService.EXTRA_ID, id)
                                putExtra(MultiOverlayService.EXTRA_NAME, name)
                                putExtra(MultiOverlayService.EXTRA_TIME, time)
                                putExtra(MultiOverlayService.EXTRA_COLOR, color)
                                putExtra(MultiOverlayService.EXTRA_FRAC, frac)
                                putExtra(MultiOverlayService.EXTRA_DONE, done)
                            }
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "close" -> {
                        call.argument<String>("id")?.let {
                            MultiOverlayService.instance?.closeById(it)
                        }
                        result.success(null)
                    }
                    "closeAll" -> {
                        MultiOverlayService.instance?.closeAll()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** 프로덕션 ANR-free 지표 — 직전 세션 ANR/크래시 종료 이력 조회. */
    private fun configureAnrVitalsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ANR_VITALS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "collect" -> {
                        val sinceMs = (call.argument<Any>("sinceMs") as? Number)?.toLong() ?: 0L
                        result.success(AnrVitalsCollector.collect(applicationContext, sinceMs))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
