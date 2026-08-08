package dev.analogtimer.analog_timer.wear

import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable

/**
 * 운동 TTS 모드 워치 미러(디자인 "운동 TTS 모드" 워치 목업).
 *
 * 폰이 Data Layer(/workout/state)로 보내는 세션 상태를 미러링하고,
 * ⏸(정지)/⏭(스킵) 명령을 MessageClient(/workout/cmd)로 돌려보낸다.
 * 이어폰 없이 쓰는 사용자를 위해 햅틱 구령: rep 1회=짧은 탭, 세트 종료(휴식 진입)=더블 탭.
 */
class WearMainActivity : Activity(), DataClient.OnDataChangedListener {

    private lateinit var phaseText: TextView
    private lateinit var bigText: TextView
    private lateinit var subText: TextView
    private lateinit var controls: LinearLayout

    private var lastRep = 0
    private var lastPhase = "idle"
    private var debugReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.BLACK)
            // 원형 화면 안전 여백
            val pad = (resources.displayMetrics.density * 24).toInt()
            setPadding(pad, pad, pad, pad)
        }
        fun centered(tv: TextView) {
            tv.gravity = Gravity.CENTER
            tv.layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
        }
        phaseText = TextView(this).apply {
            textSize = 13f
            setTextColor(COLOR_ACCENT)
            centered(this)
        }
        bigText = TextView(this).apply {
            textSize = 52f
            setTextColor(Color.WHITE)
            typeface = android.graphics.Typeface.create(
                android.graphics.Typeface.DEFAULT_BOLD,
                android.graphics.Typeface.BOLD,
            )
            centered(this)
        }
        subText = TextView(this).apply {
            textSize = 11f
            setTextColor(COLOR_FAINT)
            centered(this)
        }
        controls = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }
        val stopBtn = button("⏹") { sendCmd("stop") }
        val skipBtn = button("⏭") { sendCmd("skip") }
        controls.addView(stopBtn)
        controls.addView(skipBtn)
        root.addView(phaseText)
        root.addView(bigText)
        root.addView(subText)
        root.addView(controls)
        setContentView(root)
        renderIdle()
        registerDebugReceiver()
    }

    private fun button(label: String, onTap: () -> Unit): Button =
        Button(this).apply {
            text = label
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.TRANSPARENT)
            setOnClickListener { onTap() }
        }

    override fun onResume() {
        super.onResume()
        Wearable.getDataClient(this).addListener(this)
    }

    override fun onPause() {
        Wearable.getDataClient(this).removeListener(this)
        super.onPause()
    }

    override fun onDestroy() {
        debugReceiver?.let { unregisterReceiver(it) }
        super.onDestroy()
    }

    override fun onDataChanged(events: DataEventBuffer) {
        for (e in events) {
            if (e.dataItem.uri.path != "/workout/state") continue
            val m = DataMapItem.fromDataItem(e.dataItem).dataMap
            runOnUiThread {
                applyState(
                    phase = m.getString("phase") ?: "idle",
                    name = m.getString("name") ?: "",
                    set = m.getInt("set"),
                    sets = m.getInt("sets"),
                    rep = m.getInt("rep"),
                    reps = m.getInt("reps"),
                    t = m.getInt("t"),
                    type = m.getString("type") ?: "reps",
                )
            }
        }
    }

    private fun applyState(
        phase: String,
        name: String,
        set: Int,
        sets: Int,
        rep: Int,
        reps: Int,
        t: Int,
        type: String,
    ) {
        // 햅틱 구령 — rep 증가=탭 1회, 휴식 진입(세트 종료)=더블 탭.
        if (phase == "work" && rep > lastRep) vibrate(longArrayOf(0, 40))
        if (phase == "rest" && lastPhase != "rest") vibrate(longArrayOf(0, 50, 120, 50))
        lastRep = if (phase == "work") rep else 0
        lastPhase = phase

        when (phase) {
            "idle" -> renderIdle()
            "done" -> {
                phaseText.text = "완료"
                phaseText.setTextColor(COLOR_GREEN)
                bigText.text = "✓"
                bigText.setTextColor(COLOR_GREEN)
                subText.text = ""
                controls.visibility = View.GONE
            }
            "rest" -> {
                phaseText.text = "휴식"
                phaseText.setTextColor(COLOR_BLUE)
                bigText.text = "$t"
                bigText.setTextColor(Color.WHITE)
                subText.text = ""
                controls.visibility = View.VISIBLE
            }
            else -> { // work
                phaseText.text = name
                phaseText.setTextColor(COLOR_ACCENT)
                bigText.text = if (type == "time") "$t" else if (rep > 0) "$rep" else "–"
                bigText.setTextColor(Color.WHITE)
                subText.text = if (type == "reps") "$set/${sets}세트 · ${reps}회" else ""
                controls.visibility = View.VISIBLE
            }
        }
    }

    private fun renderIdle() {
        phaseText.text = "운동 모드"
        phaseText.setTextColor(COLOR_MUTED)
        bigText.text = "▶"
        bigText.setTextColor(COLOR_ACCENT)
        subText.text = "폰에서 루틴을 시작하세요"
        controls.visibility = View.GONE
    }

    private fun sendCmd(cmd: String) {
        vibrate(longArrayOf(0, 30))
        Wearable.getNodeClient(this).connectedNodes.addOnSuccessListener { nodes ->
            for (n in nodes) {
                Wearable.getMessageClient(this)
                    .sendMessage(n.id, "/workout/cmd", cmd.toByteArray())
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun vibrate(pattern: LongArray) {
        val v = getSystemService(VIBRATOR_SERVICE) as? Vibrator ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            v.vibrate(VibrationEffect.createWaveform(pattern, -1))
        } else {
            v.vibrate(pattern, -1)
        }
    }

    /** 디버그 전용 — 페어링 없는 에뮬레이터에서 상태 렌더를 검증하기 위한 주입 경로.
     *  adb shell am broadcast -a dev.analogtimer.WEAR_DEBUG_STATE --es phase work ... */
    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    private fun registerDebugReceiver() {
        val r = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                intent ?: return
                applyState(
                    phase = intent.getStringExtra("phase") ?: "idle",
                    name = intent.getStringExtra("name") ?: "스쿼트",
                    set = intent.getStringExtra("set")?.toIntOrNull() ?: 1,
                    sets = intent.getStringExtra("sets")?.toIntOrNull() ?: 3,
                    rep = intent.getStringExtra("rep")?.toIntOrNull() ?: 0,
                    reps = intent.getStringExtra("reps")?.toIntOrNull() ?: 10,
                    t = intent.getStringExtra("t")?.toIntOrNull() ?: 0,
                    type = intent.getStringExtra("type") ?: "reps",
                )
            }
        }
        debugReceiver = r
        val filter = IntentFilter("dev.analogtimer.WEAR_DEBUG_STATE")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(r, filter, RECEIVER_EXPORTED)
        } else {
            registerReceiver(r, filter)
        }
    }

    companion object {
        val COLOR_ACCENT = Color.parseColor("#F0C040")
        val COLOR_GREEN = Color.parseColor("#2EA84A")
        val COLOR_BLUE = Color.parseColor("#52B0E0")
        val COLOR_MUTED = Color.parseColor("#908E8A")
        val COLOR_FAINT = Color.parseColor("#7C7A76")
    }
}
