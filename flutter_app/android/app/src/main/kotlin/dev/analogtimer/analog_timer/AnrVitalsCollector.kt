package dev.analogtimer.analog_timer

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.os.Build

/**
 * 프로덕션 ANR-free 지표용 — 직전 세션들의 ANR/크래시 종료를 시스템에서 읽는다.
 *
 * `ActivityManager.getHistoricalProcessExitReasons()`(API 30+)는 프로세스 종료
 * 이력을 REASON_ANR(6) 등으로 노출한다. 앱 시작 시 커서 이후분만 수집해 텔레메트리로
 * 보낸다(중복 방지는 Dart 커서). API 30 미만은 측정 불능(measurable=false) → 분모 제외.
 *
 * 6σ 판정의 1차 권위 소스는 Play Console Android Vitals(전체 설치 기반)이고, 이 자체
 * 수집은 breadcrumb 맥락·버전 회귀의 2차 보강이다.
 */
object AnrVitalsCollector {

    /** sinceMs 이후에 발생한 종료 이력을 맵 리스트로 반환. API<30 이면 빈 목록. */
    fun collect(context: Context, sinceMs: Long): Map<String, Any> {
        val pkgInfo = runCatching {
            context.packageManager.getPackageInfo(context.packageName, 0)
        }.getOrNull()
        val versionName = pkgInfo?.versionName ?: ""
        @Suppress("DEPRECATION")
        val versionCode = pkgInfo?.longVersionCode ?: pkgInfo?.versionCode?.toLong() ?: 0L
        val sdkInt = Build.VERSION.SDK_INT

        val base = mutableMapOf<String, Any>(
            "sdkInt" to sdkInt,
            "versionName" to versionName,
            "versionCode" to versionCode,
            "measurable" to (sdkInt >= Build.VERSION_CODES.R),
        )

        if (sdkInt < Build.VERSION_CODES.R) {
            base["exits"] = emptyList<Map<String, Any>>()
            return base
        }

        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val reasons = runCatching {
            am.getHistoricalProcessExitReasons(context.packageName, 0, 0)
        }.getOrNull() ?: emptyList()

        val exits = reasons
            .filter { it.timestamp > sinceMs }
            .map { ai ->
                mapOf(
                    "reason" to ai.reason,
                    "timestampMs" to ai.timestamp,
                    "importance" to ai.importance,
                    // IMPORTANCE_FOREGROUND(100) 이면 "사용자-인지" 종료에 가깝다.
                    "userPerceived" to (ai.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND),
                    "description" to (ai.description ?: ""),
                    "processName" to ai.processName,
                    "pssKb" to ai.pss,
                    "rssKb" to ai.rss,
                    "isAnr" to (ai.reason == ApplicationExitInfo.REASON_ANR),
                )
            }
        base["exits"] = exits
        return base
    }
}
