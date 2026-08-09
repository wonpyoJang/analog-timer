package dev.analogtimer.analog_timer

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dev.analogtimer/widget"
    private val MULTI_OVERLAY_CHANNEL = "dev.analogtimer/multi_overlay"
    private val ANR_VITALS_CHANNEL = "dev.analogtimer/anr_vitals"
    private val AUDIO_FOCUS_CHANNEL = "dev.analogtimer/audio_focus"
    private val WEAR_CHANNEL = "dev.analogtimer/wear"
    private val DEEPLINK_CHANNEL = "dev.analogtimer/deeplink"
    private val SHORTCUTS_CHANNEL = "dev.analogtimer/shortcuts"

    // 콜드 스타트로 들어온 딥링크를 Dart 준비 전까지 보관(§7 콜드 경로).
    private var pendingDeepLink: String? = null
    private var deeplinkChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        TimerNotificationManager.createChannel(this)
        configureMultiOverlayChannel(flutterEngine)
        configureAnrVitalsChannel(flutterEngine)
        configureAudioFocusChannel(flutterEngine)
        configureWearChannel(flutterEngine)
        configureDeeplinkChannel(flutterEngine)
        configureShortcutsChannel(flutterEngine)

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
                    "testAlarm" -> {
                        TimerNotificationManager.testAlarm(
                            this,
                            call.argument<String>("title") ?: "Analog Timer",
                            call.argument<String>("body") ?: "",
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** 엔진 없는 네이티브 멀티 오버레이 브리지 — [MultiOverlayService] 로 명령을 startService 전달. */
    private fun configureMultiOverlayChannel(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, MULTI_OVERLAY_CHANNEL,
        )
        // pill 탭 → Dart(프리-알림 +5분 연장, 페르소나 §5).
        MultiOverlayService.onPillTap = { id ->
            runOnUiThread { channel.invokeMethod("pillTap", id) }
        }
        channel
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "show", "update" -> {
                        val id = call.argument<String>("id")
                        val name = call.argument<String>("name") ?: ""
                        val color = (call.argument<Any>("color") as? Number)?.toInt()
                            ?: MultiOverlayService.DEFAULT_ACCENT
                        val totalMs = (call.argument<Any>("totalMs") as? Number)?.toLong() ?: 0L
                        val remainMs = (call.argument<Any>("remainMs") as? Number)?.toLong() ?: 0L
                        val running = call.argument<Boolean>("running") ?: false
                        val done = call.argument<Boolean>("done") ?: false
                        val doneText = call.argument<String>("doneText") ?: ""
                        val deadlineMs = (call.argument<Any>("deadlineMs") as? Number)?.toLong() ?: 0L
                        val preAlarmMs = (call.argument<Any>("preAlarmMs") as? Number)?.toLong() ?: 0L
                        val svc = MultiOverlayService.instance
                        if (svc != null && id != null) {
                            // 서비스 기동 상태 — 직접 갱신(상태 변화 시에만; 매초 표시는 네이티브 자체 틱).
                            svc.showOrUpdate(id, name, color, totalMs, remainMs, running, done, doneText, deadlineMs, preAlarmMs)
                        } else {
                            // 콜드 스타트(첫 표시) — startService 로 시작(포그라운드 상태라 허용,
                            // onCreate 에서 startForeground 승격 → FGS 데드라인 ANR 없음).
                            val intent = Intent(this, MultiOverlayService::class.java).apply {
                                putExtra(MultiOverlayService.EXTRA_CMD, MultiOverlayService.CMD_SHOW)
                                putExtra(MultiOverlayService.EXTRA_ID, id)
                                putExtra(MultiOverlayService.EXTRA_NAME, name)
                                putExtra(MultiOverlayService.EXTRA_COLOR, color)
                                putExtra(MultiOverlayService.EXTRA_TOTAL_MS, totalMs)
                                putExtra(MultiOverlayService.EXTRA_REMAIN_MS, remainMs)
                                putExtra(MultiOverlayService.EXTRA_RUNNING, running)
                                putExtra(MultiOverlayService.EXTRA_DONE, done)
                                putExtra(MultiOverlayService.EXTRA_DONE_TEXT, doneText)
                                putExtra(MultiOverlayService.EXTRA_DEADLINE_MS, deadlineMs)
                                putExtra(MultiOverlayService.EXTRA_PREALARM_MS, preAlarmMs)
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
                    "capacity" -> {
                        result.success(MultiOverlayService.slotCapacity(applicationContext))
                    }
                    "setDisplayPrefs" -> {
                        // 표시 설정(§D) — companion 에 저장하고 살아있는 pill 은 재생성해 반영.
                        MultiOverlayService.prefSizeDp =
                            (call.argument<Any>("sizeDp") as? Number)?.toInt()
                                ?: MultiOverlayService.DIAMETER_DP
                        MultiOverlayService.prefSideRight =
                            call.argument<Boolean>("sideRight") ?: false
                        MultiOverlayService.prefShowName =
                            call.argument<Boolean>("showName") ?: true
                        MultiOverlayService.prefShowOnLock =
                            call.argument<Boolean>("showOnLock") ?: false
                        MultiOverlayService.instance?.reapplyLayout()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** 운동 TTS 워치 미러 — 폰→워치 상태 push(Data Layer), 워치→폰 명령(stop/skip) 수신. */
    private var wearChannel: MethodChannel? = null
    private val wearMessageListener =
        com.google.android.gms.wearable.MessageClient.OnMessageReceivedListener { event ->
            if (event.path == "/workout/cmd") {
                val cmd = String(event.data)
                runOnUiThread {
                    wearChannel?.invokeMethod("command", cmd)
                }
            }
        }

    private fun configureWearChannel(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, WEAR_CHANNEL,
        )
        wearChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "pushState" -> {
                    try {
                        val req = com.google.android.gms.wearable.PutDataMapRequest
                            .create("/workout/state")
                        val m = req.dataMap
                        m.putString("phase", call.argument<String>("phase") ?: "idle")
                        m.putString("name", call.argument<String>("name") ?: "")
                        m.putString("type", call.argument<String>("type") ?: "reps")
                        m.putInt("set", call.argument<Int>("set") ?: 0)
                        m.putInt("sets", call.argument<Int>("sets") ?: 0)
                        m.putInt("rep", call.argument<Int>("rep") ?: 0)
                        m.putInt("reps", call.argument<Int>("reps") ?: 0)
                        m.putInt("t", call.argument<Int>("t") ?: 0)
                        m.putLong("ts", System.currentTimeMillis()) // 동일값 dedup 방지
                        com.google.android.gms.wearable.Wearable.getDataClient(this)
                            .putDataItem(req.asPutDataRequest().setUrgent())
                    } catch (_: Exception) {} // 워치 미페어링 등 — 조용히 무시
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        try {
            com.google.android.gms.wearable.Wearable.getMessageClient(this)
                .addListener(wearMessageListener)
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        try {
            com.google.android.gms.wearable.Wearable.getMessageClient(this)
                .removeListener(wearMessageListener)
        } catch (_: Exception) {}
        super.onDestroy()
    }

    // 딥링크(음성 연동 기획 §3·§7) — anytime:// 스킴 수신.
    // 콜드: onCreate 시 intent 를 보관 → Dart 가 getInitialLink 로 흡수.
    // 웜: singleTop 이라 onNewIntent 로 들어옴 → 채널로 즉시 push.
    private fun configureDeeplinkChannel(flutterEngine: FlutterEngine) {
        deeplinkChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEEPLINK_CHANNEL,
        )
        // 콜드 스타트로 들어온 링크 보관.
        (intent?.takeIf { it.action == Intent.ACTION_VIEW }?.data?.toString())
            ?.let { pendingDeepLink = it }
        deeplinkChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(pendingDeepLink)
                    pendingDeepLink = null
                }
                "openRoutines" -> result.success(openRoutinesApp())
                else -> result.notImplemented()
            }
        }
    }

    /** 갤럭시 "모드와 루틴" 앱 실행(음성 연동 §5). 없으면 false 로 폴백. */
    private fun openRoutinesApp(): Boolean {
        val pkgs = listOf(
            "com.samsung.android.app.routines",
            "com.samsung.android.bixby.agent",
        )
        for (p in pkgs) {
            val i = packageManager.getLaunchIntentForPackage(p)
            if (i != null) {
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                return try {
                    startActivity(i); true
                } catch (_: Exception) {
                    false
                }
            }
        }
        return false
    }

    /** 동적 앱 단축어(음성 연동 §4) — 런처 아이콘 롱프레스 목록. 각 단축어는
     *  anytime:// 딥링크를 VIEW 인텐트로 실어 우리 액티비티를 연다. 최대 8개. */
    private fun configureShortcutsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUTS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setShortcuts" -> {
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val items = call.argument<List<Map<String, String>>>("items")
                                ?: emptyList()
                            val icon = androidx.core.graphics.drawable.IconCompat
                                .createWithResource(this, R.mipmap.ic_launcher)
                            val shortcuts = items.take(8).mapNotNull { m ->
                                val id = m["id"] ?: return@mapNotNull null
                                val link = m["link"] ?: return@mapNotNull null
                                val short = m["short"] ?: id
                                val long = m["long"] ?: short
                                val intent = Intent(
                                    Intent.ACTION_VIEW,
                                    android.net.Uri.parse(link),
                                    this,
                                    MainActivity::class.java,
                                )
                                androidx.core.content.pm.ShortcutInfoCompat
                                    .Builder(this, id)
                                    .setShortLabel(short)
                                    .setLongLabel(long)
                                    .setIcon(icon)
                                    .setIntent(intent)
                                    .build()
                            }
                            androidx.core.content.pm.ShortcutManagerCompat
                                .setDynamicShortcuts(this, shortcuts)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == Intent.ACTION_VIEW) {
            val uri = intent.data?.toString() ?: return
            val ch = deeplinkChannel
            if (ch != null) {
                runOnUiThread { ch.invokeMethod("link", uri) }
            } else {
                pendingDeepLink = uri // 엔진 준비 전이면 보관
            }
        }
    }

    /** 운동 TTS 음악 덕킹 — 발화 동안 TRANSIENT_MAY_DUCK 포커스를 잡아
     *  시스템이 백그라운드 음악 볼륨을 낮추게 한다(스펙 §06 음악 덕킹). */
    private var duckFocusRequest: android.media.AudioFocusRequest? = null

    private fun configureAudioFocusChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_FOCUS_CHANNEL)
            .setMethodCallHandler { call, result ->
                val am = getSystemService(AUDIO_SERVICE) as android.media.AudioManager
                when (call.method) {
                    "duck" -> {
                        if (duckFocusRequest == null) {
                            val attrs = android.media.AudioAttributes.Builder()
                                .setUsage(android.media.AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE)
                                .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SPEECH)
                                .build()
                            val req = android.media.AudioFocusRequest
                                .Builder(android.media.AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                                .setAudioAttributes(attrs)
                                .build()
                            am.requestAudioFocus(req)
                            duckFocusRequest = req
                        }
                        result.success(null)
                    }
                    "release" -> {
                        duckFocusRequest?.let { am.abandonAudioFocusRequest(it) }
                        duckFocusRequest = null
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
