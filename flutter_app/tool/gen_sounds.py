#!/usr/bin/env python3
"""멀티 타이머 효과음 합성 — 디자인 '모션 & 사운드 스펙.html'의 WebAudio 파라미터를 .wav 로.

사용: python3 tool/gen_sounds.py  →  assets/sounds/{set}_{event}.wav 생성
각 톤: (freq, t0, dur, type, vol[, glideTo]) — 스펙의 tone() 인자와 동일.
"""

import math
import os
import struct
import wave

SR = 44100

# 디자인 스펙의 SETS 그대로 (주파수 Hz, 시작 s, 길이 s, 파형, 볼륨, [글라이드 목표 Hz])
SETS = {
    "pop": {
        "tap": [(660, 0, .06, "triangle", .3)],
        "add": [(520, 0, .07, "sine", .25), (780, .07, .09, "sine", .25)],
        "start": [(440, 0, .09, "sine", .28)],
        "pause": [(440, 0, .1, "sine", .22, 330)],
        "warn": [(880, 0, .05, "square", .15), (880, .12, .05, "square", .15)],
        "done": [(523, 0, .12, "triangle", .28), (659, .11, .12, "triangle", .28),
                 (784, .22, .18, "triangle", .28)],
        "snap": [(340, 0, .045, "triangle", .3)],
        "del": [(300, 0, .14, "sawtooth", .12, 150)],
    },
    "wood": {
        "tap": [(520, 0, .035, "triangle", .35)],
        "add": [(420, 0, .04, "triangle", .3), (560, .06, .04, "triangle", .3)],
        "start": [(480, 0, .05, "triangle", .32)],
        "pause": [(380, 0, .05, "triangle", .26)],
        "warn": [(640, 0, .035, "triangle", .3), (640, .1, .035, "triangle", .3)],
        "done": [(440, 0, .05, "triangle", .32), (550, .08, .05, "triangle", .32),
                 (660, .16, .07, "triangle", .32)],
        "snap": [(300, 0, .03, "triangle", .32)],
        "del": [(260, 0, .06, "triangle", .2, 180)],
    },
    "glass": {
        "tap": [(1320, 0, .18, "sine", .16)],
        "add": [(1046, 0, .22, "sine", .14), (1568, .09, .28, "sine", .12)],
        "start": [(880, 0, .3, "sine", .18)],
        "pause": [(880, 0, .25, "sine", .14, 660)],
        "warn": [(1760, 0, .12, "sine", .12), (1760, .16, .12, "sine", .12)],
        "done": [(1046, 0, .3, "sine", .16), (1318, .12, .3, "sine", .14),
                 (1568, .24, .45, "sine", .14)],
        "snap": [(988, 0, .12, "sine", .14)],
        "del": [(740, 0, .25, "sine", .1, 370)],
    },
    "retro": {
        "tap": [(660, 0, .05, "square", .12)],
        "add": [(392, 0, .05, "square", .12), (523, .05, .05, "square", .12),
                (659, .1, .06, "square", .12)],
        "start": [(523, 0, .08, "square", .13)],
        "pause": [(523, 0, .09, "square", .11, 262)],
        "warn": [(988, 0, .04, "square", .11), (988, .08, .04, "square", .11),
                 (988, .16, .04, "square", .11)],
        "done": [(523, 0, .07, "square", .13), (659, .07, .07, "square", .13),
                 (784, .14, .07, "square", .13), (1046, .21, .12, "square", .13)],
        "snap": [(262, 0, .04, "square", .13)],
        "del": [(400, 0, .12, "square", .09, 100)],
    },
}


def osc(kind, phase):
    x = phase % 1.0
    if kind == "sine":
        return math.sin(2 * math.pi * x)
    if kind == "square":
        return 1.0 if x < 0.5 else -1.0
    if kind == "triangle":
        return 4 * abs(x - 0.5) - 1
    if kind == "sawtooth":
        return 2 * x - 1
    raise ValueError(kind)


def render(tones):
    total = max(t[1] + t[2] for t in tones) + 0.06
    n = int(total * SR)
    buf = [0.0] * n
    for t in tones:
        f0, t0, dur, kind, vol = t[0], t[1], t[2], t[3], t[4]
        f1 = t[5] if len(t) > 5 else None
        start = int(t0 * SR)
        cnt = int(dur * SR)
        phase = 0.0
        for i in range(cnt):
            ts = i / SR
            # WebAudio exponentialRamp 와 동일한 지수 글라이드
            f = f0 if f1 is None else f0 * (f1 / f0) ** (ts / dur)
            phase += f / SR
            # 어택 8ms 선형, 이후 지수 감쇠(→0.001)
            env = (ts / 0.008) if ts < 0.008 else (0.001 ** ((ts - 0.008) / max(dur - 0.008, 1e-4)))
            j = start + i
            if j < n:
                buf[j] += osc(kind, phase) * vol * env
    return buf


def write_wav(path, buf):
    frames = b"".join(
        struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in buf
    )
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(frames)


def main():
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")
    os.makedirs(out, exist_ok=True)
    for set_name, events in SETS.items():
        for ev, tones in events.items():
            path = os.path.join(out, f"{set_name}_{ev}.wav")
            write_wav(path, render(tones))
            print(f"{set_name}_{ev}.wav")


if __name__ == "__main__":
    main()
