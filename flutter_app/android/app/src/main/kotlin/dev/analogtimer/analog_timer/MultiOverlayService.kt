package dev.analogtimer.analog_timer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat

/**
 * 엔진 없는 네이티브 멀티 오버레이 — 실행 중 카운트다운 타이머마다 독립 원형 창을 띄운다.
 *
 * flutter_overlay_window(FlutterEngine 1개 + FlutterView 1개, 단일 창)와 달리
 * 이 서비스는 FlutterEngine을 전혀 쓰지 않고 순수 Android View를 WindowManager에
 * id별로 addView 한다 → 창을 N개 띄워도 엔진 메모리(창당 ~10–20MB)가 0.
 *
 * 각 창은 [CircleTimerView] — 원 둘레를 진행 링으로, 중앙에 이름·남은시간을 그린다.
 * 메인 앱(MultiTimerBloc)이 MethodChannel → startService(Intent) 로 show/update/close
 * 명령을 보내면 onStartCommand 가 해당 id의 View 를 만들거나 갱신·제거한다.
 */
class MultiOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private val pills = HashMap<String, PillHandle>()
    private var foregroundStarted = false
    private val handler = Handler(Looper.getMainLooper())
    private var pendingStop: Runnable? = null

    /** 드래그 중인 창 id — 그 창의 초 단위 콘텐츠 갱신(invalidate)을 억제해 이동과 경쟁 방지. */
    private var draggingId: String? = null

    private class PillHandle(
        val view: CircleTimerView,
        val params: WindowManager.LayoutParams,
    )

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createChannel()
        // startForegroundService() 는 5초 내 startForeground() 를 강제한다(미이행 시 ANR).
        // 반드시 승격을 먼저 하고 instance 를 공개한다 — 순서가 바뀌면, 아직 승격 전인
        // 서비스에 토글-OFF(closeById→stopSelf)가 끼어들어 "brought down while waiting" ANR.
        ensureForeground()
        instance = this
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 어떤 경로(콜드스타트/재사용/즉시 stop)에서도 startForegroundService 데드라인을
        // 충족하도록 승격을 최우선으로. 그 다음 instance 공개.
        ensureForeground()
        instance = this
        // Intent 경로는 콜드 스타트(첫 show)에만 쓰인다 — 이후 갱신은 정적 인스턴스로 직접 호출.
        when (intent?.getStringExtra(EXTRA_CMD)) {
            CMD_SHOW, CMD_UPDATE -> {
                val id = intent.getStringExtra(EXTRA_ID)
                if (id != null) showOrUpdate(
                    id,
                    intent.getStringExtra(EXTRA_NAME) ?: "",
                    intent.getIntExtra(EXTRA_COLOR, DEFAULT_ACCENT),
                    intent.getLongExtra(EXTRA_TOTAL_MS, 0L),
                    intent.getLongExtra(EXTRA_REMAIN_MS, 0L),
                    intent.getBooleanExtra(EXTRA_RUNNING, false),
                    intent.getBooleanExtra(EXTRA_DONE, false),
                    intent.getStringExtra(EXTRA_DONE_TEXT) ?: "",
                    intent.getLongExtra(EXTRA_DEADLINE_MS, 0L),
                )
            }
            CMD_CLOSE -> handleClose(intent.getStringExtra(EXTRA_ID))
            CMD_CLOSE_ALL -> closeAll()
        }
        scheduleStopIfEmpty()
        return START_NOT_STICKY
    }

    /** id 창을 만들거나 갱신한다. 상태 변화 시에만 호출되고(매초 아님), 이후 표시는
     *  네이티브 뷰가 [tickRunnable] 로 자체 갱신한다. */
    fun showOrUpdate(
        id: String,
        name: String,
        color: Int,
        totalMs: Long,
        remainMs: Long,
        running: Boolean,
        done: Boolean,
        doneText: String,
        deadlineEpochMs: Long = 0L,
    ) {
        cancelPendingStop() // 다시 켜짐 — 예약된 정지 취소
        val existing = pills[id]
        if (existing != null) {
            // 드래그 중인 창도 상태(running/시간)는 반영하되 invalidate 는 refresh 결과에 맡긴다.
            existing.view.setState(name, color, totalMs, remainMs, running, done, doneText, deadlineEpochMs)
        } else {
            addPill(id, name, color, totalMs, remainMs, running, done, doneText, deadlineEpochMs)
        }
        ensureTicking()
    }

    private var tickScheduled = false

    /** running 창이 하나라도 있으면 매초 자체 갱신을 돌린다(초 바뀔 때만 invalidate). */
    private fun ensureTicking() {
        if (tickScheduled) return
        tickScheduled = true
        handler.post(tickRunnable)
    }

    private val tickRunnable = object : Runnable {
        override fun run() {
            var anyRunning = false
            var minRemain = Long.MAX_VALUE
            for ((id, h) in pills) {
                if (!h.view.running) continue
                anyRunning = true
                val r = h.view.currentRemainMs()
                if (r < minRemain) minRemain = r
                if (id == draggingId) continue // 드래그 중엔 invalidate 억제
                val ch = h.view.refresh()
                if (ch) h.view.invalidate()
            }
            if (anyRunning) {
                // 다음 초 경계 직후로 정렬 — 고정 주기(500ms)면 표시가 최대 그만큼 늦게
                // 바뀌어 리스트와 1초 어긋나 보인다. 경계 +30ms 에 깨우면 지연이 수십 ms.
                val next = if (minRemain == Long.MAX_VALUE) 500L
                    else ((minRemain % 1000) + 30).coerceIn(50, 1000)
                handler.postDelayed(this, next)
            } else {
                tickScheduled = false
            }
        }
    }

    /** id 창을 닫는다. 마지막이 닫히면 즉시 stop 하지 않고 디바운스 예약한다. */
    fun closeById(id: String) {
        handleClose(id)
        scheduleStopIfEmpty()
    }

    // 개별 OFF 마다 즉시 stopSelf 하면, 곧이은 ON 의 startForegroundService 와 레이스가 나서
    // "Bringing down service while still waiting for start foreground" ANR 이 난다.
    // 비면 1.5s 뒤 정지를 예약하고, 그 사이 다시 켜지면 취소해 churn 을 없앤다.
    private fun scheduleStopIfEmpty() {
        if (pills.isNotEmpty()) return
        cancelPendingStop()
        val r = Runnable {
            pendingStop = null
            if (pills.isEmpty()) stopSelfSafely()
        }
        pendingStop = r
        handler.postDelayed(r, 1500)
    }

    private fun cancelPendingStop() {
        pendingStop?.let { handler.removeCallbacks(it) }
        pendingStop = null
    }

    private fun handleClose(id: String?) {
        id ?: return
        if (id == draggingId) draggingId = null
        val handle = pills.remove(id) ?: return
        runCatching { windowManager.removeView(handle.view) }
    }

    fun closeAll() {
        // 화면 이탈(dispose) 등 전체 종료 — 디바운스 없이 즉시 정지.
        cancelPendingStop()
        draggingId = null
        for (handle in pills.values) runCatching { windowManager.removeView(handle.view) }
        pills.clear()
        stopSelfSafely()
    }

    // ----- 원형 View 창 -----

    private fun addPill(
        id: String,
        name: String,
        color: Int,
        totalMs: Long,
        remainMs: Long,
        running: Boolean,
        done: Boolean,
        doneText: String,
        deadlineEpochMs: Long = 0L,
    ) {
        val view = CircleTimerView(this)
        view.setState(name, color, totalMs, remainMs, running, done, doneText, deadlineEpochMs)

        val size = dp(DIAMETER_DP)
        val params = WindowManager.LayoutParams(
            size,
            size,
            overlayWindowType(),
            // Service context 로 addView 한 창은 HW 가속이 기본 OFF → 이동 시 Canvas(anti-alias
            // arc·text)를 CPU 로 매번 재래스터해 드래그가 끊긴다. HW_ACCELERATED 로 GPU 합성.
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            // 기존 오버레이(제거/드래그로 위치가 제각각)와 겹치지 않는 빈 자리를 찾아 스폰.
            val pos = findFreePosition(size)
            x = pos.first
            y = pos.second
        }

        val handle = PillHandle(view, params)
        attachDrag(id, handle)
        runCatching { windowManager.addView(view, params) }
            .exceptionOrNull()?.let { Log.e(TAG, "addView failed id=$id", it) }
        pills[id] = handle
    }

    /** 기존 오버레이와 겹치지 않는 스폰 위치. 좌→우 열, 각 열은 위→아래 슬롯을 훑는다.
     *  단일 오버레이(시계) 창이 떠 있으면(상호 배타 OFF 동시 사용) 그 rect 도 회피한다. */
    private fun findFreePosition(size: Int): Pair<Int, Int> {
        val gap = dp(10)
        val startX = dp(12)
        val startY = dp(72)
        val step = size + gap
        val dm = resources.displayMetrics
        val maxY = dm.heightPixels - size - dp(24)
        val maxX = dm.widthPixels - size - dp(12)
        val clockRect = runCatching {
            flutter.overlay.window.flutter_overlay_window.OverlayService.getWindowRect()
        }.getOrNull()

        fun overlaps(x: Int, y: Int): Boolean {
            if (clockRect != null &&
                x < clockRect.right + gap && x + size + gap > clockRect.left &&
                y < clockRect.bottom + gap && y + size + gap > clockRect.top
            ) {
                return true
            }
            return pills.values.any { h ->
                val px = h.params.x
                val py = h.params.y
                // 슬롯 간 최소 간격(gap)만큼 떨어져 있지 않으면 겹침으로 간주.
                x < px + size + gap && x + size + gap > px &&
                    y < py + size + gap && y + size + gap > py
            }
        }

        var x = startX
        while (x <= maxX) {
            var y = startY
            while (y <= maxY) {
                if (!overlaps(x, y)) return x to y
                y += step
            }
            x += step
        }
        // 화면이 꽉 참(상한 초과) — 마지막 수단으로 계단식 오프셋.
        val n = pills.size
        return (startX + dp(16) * (n % 5)) to (startY + dp(16) * (n % 8))
    }

    /** 원 둘레를 진행 링으로 그리고 중앙에 이름·남은시간을 표시하는 커스텀 View.
     *  마감시각(deadline)을 들고 자체적으로 매초 남은시간을 계산한다 — 매초 push 에 의존하지
     *  않으므로 플랫폼 스레드가 바빠도(다른 오버레이 엔진 등) 표시 시간이 정확하다. */
    private inner class CircleTimerView(context: Context) : View(context) {
        var timerName: String = ""
            private set
        var timeText: String = ""
            private set
        var running: Boolean = false
            private set
        private var color: Int = DEFAULT_ACCENT
        private var frac: Float = 1f
        private var done: Boolean = false
        private var doneText: String = ""
        private var totalMs: Long = 0
        private var deadlineMs: Long = 0 // running 일 때 마감 절대시각
        private var frozenRemainMs: Long = 0 // paused/done 일 때 고정 남은시간

        private val ringStroke = dp(9).toFloat()
        private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
        private val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = ringStroke
            color = 0x33FFFFFF
        }
        private val arcPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = ringStroke
            strokeCap = Paint.Cap.ROUND
        }
        private val namePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize = sp(11f)
            color = 0xFFB8B8BC.toInt()
        }
        private val timePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize = sp(19f)
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
        }
        private val arcRect = RectF()

        /** 상태 변화 시에만 호출(start/pause/reset/complete/rename). running 이면 마감시각을 잡고,
         *  이후엔 [refresh] 가 자체적으로 남은시간을 계산한다.
         *  [deadlineEpochMs] 는 Dart 가 push 시점에 계산한 마감 절대시각 — 이걸 쓰면 채널
         *  전달 지연이 표시 시간에 끼어들지 않는다(0 이면 도착시각 기준 폴백). */
        fun setState(
            name: String,
            colorArgb: Int,
            totalMsArg: Long,
            remainMs: Long,
            isRunning: Boolean,
            isDone: Boolean,
            doneLabel: String,
            deadlineEpochMs: Long = 0L,
        ) {
            timerName = name
            color = colorArgb
            totalMs = totalMsArg
            done = isDone
            doneText = doneLabel
            running = isRunning && !isDone
            if (running) {
                deadlineMs = if (deadlineEpochMs > 0) deadlineEpochMs
                    else System.currentTimeMillis() + remainMs.coerceAtLeast(0)
            } else {
                frozenRemainMs = remainMs.coerceAtLeast(0)
            }
            refresh()
            invalidate()
        }

        fun currentRemainMs(): Long =
            if (running) (deadlineMs - System.currentTimeMillis()).coerceAtLeast(0)
            else frozenRemainMs

        /** 표시(시간 문자열·진행률)를 현재 남은시간으로 재계산. 표시가 바뀌었으면 true. */
        fun refresh(): Boolean {
            val remain = currentRemainMs()
            val newText = if (done) doneText else fmt(remain)
            val newFrac = if (done) 1f
                else if (totalMs <= 0) 0f
                else (1f - remain.toFloat() / totalMs).coerceIn(0f, 1f)
            val changed = newText != timeText || newFrac != frac
            timeText = newText
            frac = newFrac
            return changed
        }

        /** Dart _fmt 와 동일: ceil(remainMs/1000) 초를 h:mm:ss / mm:ss 로. */
        private fun fmt(remainMs: Long): String {
            val totalSec = ((remainMs + 999) / 1000).toInt()
            val h = totalSec / 3600
            val m = (totalSec % 3600) / 60
            val s = totalSec % 60
            return if (h > 0) "%d:%02d:%02d".format(h, m, s)
            else "%02d:%02d".format(m, s)
        }

        override fun onDraw(canvas: Canvas) {
            val cx = width / 2f
            val cy = height / 2f
            val pad = ringStroke / 2f + dp(2)
            val r = minOf(width, height) / 2f - pad

            // 원 배경(어두운 반투명) — 링 안쪽을 채워 텍스트 가독성 확보
            bgPaint.color = 0xF01A1A1C.toInt()
            canvas.drawCircle(cx, cy, r - ringStroke / 2f, bgPaint)

            // 둘레 트랙 + 진행 아크(12시 방향에서 시계방향)
            arcRect.set(cx - r, cy - r, cx + r, cy + r)
            canvas.drawCircle(cx, cy, r, trackPaint)
            arcPaint.color = color
            val sweep = (if (done) 1f else frac) * 360f
            if (sweep > 0f) canvas.drawArc(arcRect, -90f, sweep, false, arcPaint)

            // 중앙 텍스트 — 이름(위) · 남은시간(아래)
            val name = ellipsize(timerName, namePaint, r * 1.4f)
            canvas.drawText(name, cx, cy - dp(8), namePaint)
            timePaint.color = if (done) color else 0xFFFFFFFF.toInt()
            val fm = timePaint.fontMetrics
            canvas.drawText(timeText, cx, cy + dp(14) - fm.descent, timePaint)
        }

        private fun ellipsize(text: String, paint: Paint, maxWidth: Float): String {
            if (paint.measureText(text) <= maxWidth) return text
            var end = text.length
            while (end > 1 && paint.measureText(text.substring(0, end) + "…") > maxWidth) end--
            return text.substring(0, end) + "…"
        }
    }

    // ----- 드래그 (getRawX/Y 절대 오프셋; OverlayService.onTouch 패턴 복제) -----

    private fun attachDrag(id: String, handle: PillHandle) {
        var downRawX = 0f
        var downRawY = 0f
        var startX = 0
        var startY = 0
        var dragging = false
        var frameScheduled = false
        val slopSq = (dp(6)).let { (it * it).toFloat() }

        // MOVE 마다 updateViewLayout(WMS IPC+트래버설)을 호출하면 고주사율 입력에서 폭주한다.
        // 프레임당 1회만 최신 좌표를 반영(postOnAnimation = vsync 정렬)해 부드럽게.
        val applyLayout = Runnable {
            frameScheduled = false
            runCatching { windowManager.updateViewLayout(handle.view, handle.params) }
        }

        handle.view.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = event.rawX
                    downRawY = event.rawY
                    startX = handle.params.x
                    startY = handle.params.y
                    dragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - downRawX
                    val dy = event.rawY - downRawY
                    if (!dragging && dx * dx + dy * dy < slopSq) return@setOnTouchListener true
                    if (!dragging) {
                        dragging = true
                        draggingId = id // 드래그 시작 — 콘텐츠 갱신 억제
                    }
                    handle.params.x = startX + Math.round(dx)
                    handle.params.y = startY + Math.round(dy)
                    if (!frameScheduled) {
                        frameScheduled = true
                        handle.view.postOnAnimation(applyLayout)
                    }
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    if (dragging) {
                        dragging = false
                        if (draggingId == id) draggingId = null
                        // 마지막 좌표를 즉시 반영하고, 억제됐던 콘텐츠를 1회 갱신.
                        handle.view.removeCallbacks(applyLayout)
                        frameScheduled = false
                        runCatching { windowManager.updateViewLayout(handle.view, handle.params) }
                        handle.view.invalidate()
                    }
                    true
                }
                else -> false
            }
        }
    }

    // ----- 포그라운드/알림 -----

    private fun ensureForeground() {
        if (foregroundStarted) return
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            PendingIntent.FLAG_IMMUTABLE else PendingIntent.FLAG_UPDATE_CURRENT
        val pending = PendingIntent.getActivity(this, 0, notificationIntent, pendingFlags)
        val icon = resources.getIdentifier("ic_launcher", "mipmap", packageName)
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("멀티 타이머")
            .setContentText("타이머 오버레이 실행 중")
            .setSmallIcon(if (icon != 0) icon else android.R.drawable.ic_menu_recent_history)
            .setContentIntent(pending)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID, notification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            foregroundStarted = true
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed", e)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "멀티 타이머 오버레이", NotificationManager.IMPORTANCE_LOW,
            )
            (getSystemService(NotificationManager::class.java)).createNotificationChannel(channel)
        }
    }

    private fun stopSelfSafely() {
        // 인스턴스를 즉시 해제 — stopSelf 는 비동기라 onDestroy 전까지 살아있는데,
        // 그 사이 들어온 show() 가 죽어가는 서비스에 뷰를 붙이면 곧 제거돼 사라진다.
        // null 로 비우면 재요청이 콜드스타트 Intent 경로(새 서비스)로 안전하게 간다.
        if (instance === this) instance = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION") stopForeground(true)
        }
        foregroundStarted = false
        stopSelf()
    }

    override fun onDestroy() {
        cancelPendingStop()
        for (handle in pills.values) runCatching { windowManager.removeView(handle.view) }
        pills.clear()
        if (instance === this) instance = null
        super.onDestroy()
    }

    private fun dp(v: Int): Int = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics,
    ).toInt()

    private fun sp(v: Float): Float = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_SP, v, resources.displayMetrics,
    )

    private fun overlayWindowType(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE

    companion object {
        /** 실행 중인 서비스 인스턴스 — 매 틱 갱신을 Intent 없이 직접 호출하기 위함(같은 프로세스·메인 스레드). */
        @Volatile
        var instance: MultiOverlayService? = null
            private set

        const val TAG = "MultiOverlay"
        const val CHANNEL_ID = "multi_overlay_channel"
        const val NOTIFICATION_ID = 4611
        const val DEFAULT_ACCENT = 0xFFE07A52.toInt()
        const val DIAMETER_DP = 108

        const val EXTRA_CMD = "cmd"
        const val EXTRA_ID = "id"
        const val EXTRA_NAME = "name"
        const val EXTRA_COLOR = "color"
        const val EXTRA_TOTAL_MS = "totalMs"
        const val EXTRA_REMAIN_MS = "remainMs"
        const val EXTRA_RUNNING = "running"
        const val EXTRA_DONE = "done"
        const val EXTRA_DONE_TEXT = "doneText"
        const val EXTRA_DEADLINE_MS = "deadlineMs"

        const val CMD_SHOW = "show"
        const val CMD_UPDATE = "update"
        const val CMD_CLOSE = "close"
        const val CMD_CLOSE_ALL = "closeAll"
    }
}
