# ML Kit 텍스트 인식(OCR) — 앱은 한국어+라틴만 사용하나, 플러그인이 다른 언어
# 인식기 클래스를 정적 참조해 R8가 미포함 클래스 경고로 릴리스 빌드를 실패시킴.
# 해당 옵션 인식기(중국어·일본어·데바나가리)는 번들하지 않으므로 경고만 억제한다.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions

# ML Kit 런타임 보존 — R8 full-mode 가 ML Kit 내부(리플렉션으로 자기 클래스명을
# 읽는 코드)를 난독화/제거하면 인식 시 NullPointerException(x3.ma.<init> getClass
# on null) 으로 조용히 실패("No time found")한다. 관련 클래스를 통째로 보존한다.
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.mlkit.**
