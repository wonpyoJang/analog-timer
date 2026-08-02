"""Windows 앱 아이콘(ICO) 생성 — 크기별 최적화 렌디션.

배경: 원본 아트워크(assets/icons/app_icon.png)는 near-black 라운드 사각형 위에
어두운 시계라, 16~32px 로 축소하면 검은 덩어리가 되어 어두운 작업표시줄에서
보이지 않는다. ICO 는 크기마다 다른 그림을 담을 수 있으므로(아이콘 디자인의
표준 기법), 작은 크기는 대비를 살린 전용 그림을 그려 넣는다.

  16~32px : 배경 없이 accent 링 + 굵은 바늘만 (어떤 테마의 작업표시줄에서도 보임)
  40~64px : 어두운 원반 + accent 링 + 바늘 (깊이감 복원)
  128px~  : 원본 아트워크 그대로 (디테일이 살아나는 크기)

사용: python tool/make_icons.py   (flutter_app 디렉토리에서)
"""

from PIL import Image, ImageDraw

SRC = r"assets\icons\app_icon.png"
OUT = [r"windows\runner\resources\app_icon.ico", r"assets\icons\app_icon.ico"]

ACCENT = (240, 192, 64, 255)   # #F0C040
HAND = (232, 230, 224, 255)    # #E8E6E0
SECOND = (224, 122, 82, 255)   # #E07A52
DISC = (26, 26, 28, 255)       # #1A1A1C

SS = 8  # 슈퍼샘플 배수 — 작은 크기에서 링/바늘이 계단지지 않게


def draw_clock(size: int, with_disc: bool) -> Image.Image:
    s = size * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = s * 0.06
    box = [pad, pad, s - pad, s - pad]
    if with_disc:
        d.ellipse(box, fill=DISC)
    # 링 — 작을수록 상대적으로 두껍게 해야 형체가 남는다
    ring_w = max(2, int(s * (0.11 if size <= 20 else 0.085)))
    d.ellipse(box, outline=ACCENT, width=ring_w)

    cx = cy = s / 2
    r = (s - 2 * pad) / 2
    hand_w = max(2, int(s * (0.095 if size <= 20 else 0.075)))
    # 10시 10분 — 아이콘 관례(양쪽으로 벌어져 형태가 또렷)
    d.line([cx, cy, cx - r * 0.42, cy - r * 0.34], fill=HAND, width=hand_w)
    d.line([cx, cy, cx + r * 0.30, cy - r * 0.50], fill=HAND, width=hand_w)
    if size >= 32:
        d.line([cx, cy, cx + r * 0.10, cy + r * 0.56], fill=SECOND,
               width=max(2, int(hand_w * 0.55)))
        cr = s * 0.045
        d.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=SECOND)
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    art = Image.open(SRC).convert("RGBA")
    # 타이틀바 로고(14px 표시) — 어두운 바에서도 보이는 링 렌디션 PNG.
    draw_clock(64, with_disc=False).save(r"assets\icons\app_icon_small.png")
    print("생성: assets/icons/app_icon_small.png")
    images = []
    for size in (16, 20, 24, 32, 40, 48, 64, 128, 256):
        if size <= 32:
            images.append(draw_clock(size, with_disc=False))
        elif size <= 64:
            images.append(draw_clock(size, with_disc=True))
        else:
            images.append(art.resize((size, size), Image.LANCZOS))

    # Pillow 의 ICO 저장은 append_images 로 크기별 그림을 각각 담는다.
    # 주의: 베이스 이미지보다 "큰" 크기는 조용히 버려지므로(sizes 필터링),
    # 반드시 가장 큰 렌디션을 베이스로 넘겨야 한다.
    base = images[-1]
    for out in OUT:
        base.save(out, format="ICO",
                  sizes=[(i.width, i.height) for i in images],
                  append_images=images[:-1])
        print("생성:", out)


if __name__ == "__main__":
    main()
