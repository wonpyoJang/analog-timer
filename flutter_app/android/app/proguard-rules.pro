# ML Kit 텍스트 인식(OCR) — 앱은 한국어+라틴만 사용하나, 플러그인이 다른 언어
# 인식기 클래스를 정적 참조해 R8가 미포함 클래스 경고로 릴리스 빌드를 실패시킴.
# 해당 옵션 인식기(중국어·일본어·데바나가리)는 번들하지 않으므로 경고만 억제한다.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
