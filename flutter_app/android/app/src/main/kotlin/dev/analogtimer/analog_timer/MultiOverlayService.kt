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
import android.os.IBinder
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
                    intent.getStringExtra(EXTRA_TIME) ?: "--:--",
                    intent.getIntExtra(EXTRA_COLOR, DEFAULT_ACCENT),
                    intent.getFloatExtra(EXTRA_FRAC, 1f),
                    intent.getBooleanExtra(EXTRA_DONE, false),
                )
            }
            CMD_CLOSE -> handleClose(intent.getStringExtra(EXTRA_ID))
            CMD_CLOSE_ALL -> closeAll()
        }
        if (pills.isEmpty()) stopSelfSafely()
        return START_NOT_STICKY
    }

    /** id 창을 만들거나 갱신한다. 매 틱 갱신은 MainActivity 가 이 메서드를 직접 호출한다. */
    fun showOrUpdate(
        id: String,
        name: String,
        time: String,
        color: Int,
        frac: Float,
        done: Boolean,
    ) {
        val existing = pills[id]
        if (existing != null) existing.view.setState(name, time, color, frac, done)
        else addPill(id, name, time, color, frac, done)
    }

    /** id 창을 닫고, 마지막이면 서비스 종료. */
    fun closeById(id: String) {
        handleClose(id)
        if (pills.isEmpty()) stopSelfSafely()
    }

    private fun handleClose(id: String?) {
        id ?: return
        val handle = pills.remove(id) ?: return
        runCatching { windowManager.removeView(handle.view) }
    }

    fun closeAll() {
        for (handle in pills.values) runCatching { windowManager.removeView(handle.view) }
        pills.clear()
        stopSelfSafely()
    }

    // ----- 원형 View 창 -----

    private fun addPill(
        id: String,
        name: String,
        time: String,
        color: Int,
        frac: Float,
        done: Boolean,
    ) {
        val view = CircleTimerView(this)
        view.setState(name, time, color, frac, done)

        val size = dp(DIAMETER_DP)
        val params = WindowManager.LayoutParams(
            size,
            size,
            overlayWindowType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            // 새 창이 앞 창과 겹치지 않도록 좌측에 세로로 쌓는다(간격 10dp).
            x = dp(12)
            y = dp(72) + (size + dp(10)) * pills.size
        }

        val handle = PillHandle(view, params)
        attachDrag(handle)
        runCatching { windowManager.addView(view, params) }
            .exceptionOrNull()?.let { Log.e(TAG, "addView failed id=$id", it) }
        pills[id] = handle
    }

    /** 원 둘레를 진행 링으로 그리고 중앙에 이름·남은시간을 표시하는 커스텀 View. */
    private inner class CircleTimerView(context: Context) : View(context) {
        var timerName: String = ""
            private set
        var timeText: String = ""
            private set
        private var color: Int = DEFAULT_ACCENT
        private var frac: Float = 1f
        private var done: Boolean = false

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

        fun setState(name: String, time: String, colorArgb: Int, f: Float, isDone: Boolean) {
            timerName = name
            timeText = time
            color = colorArgb
            frac = f.coerceIn(0f, 1f)
            done = isDone
            invalidate()
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

    private fun attachDrag(handle: PillHandle) {
        var downRawX = 0f
        var downRawY = 0f
        var startX = 0
        var startY = 0
        var dragging = false
        val slopSq = (dp(6)).let { (it * it).toFloat() }

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
                    dragging = true
                    handle.params.x = startX + Math.round(dx)
                    handle.params.y = startY + Math.round(dy)
                    runCatching { windowManager.updateViewLayout(handle.view, handle.params) }
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> true
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
        const val EXTRA_TIME = "time"
        const val EXTRA_COLOR = "color"
        const val EXTRA_FRAC = "frac"
        const val EXTRA_DONE = "done"

        const val CMD_SHOW = "show"
        const val CMD_UPDATE = "update"
        const val CMD_CLOSE = "close"
        const val CMD_CLOSE_ALL = "closeAll"
    }
}
