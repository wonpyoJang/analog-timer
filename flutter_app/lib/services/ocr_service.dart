import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 봉지 OCR(디자인 "온디바이스 & 삼성 API 기획" §3) — 완전 온디바이스 텍스트 인식.
///
/// 조리시간은 거의 언제나 인쇄돼 있다. 그 "옮겨 적기"를 없앤다. 인식 결과 텍스트를
/// 그대로 time_parser 에 태워 시간 표현만 뽑는다(§3: 숫자가 아니라 시간 표현을 찾는다).
/// 한국어 스크립트 인식기는 한글 + 라틴/숫자를 함께 읽는다. 무료·오프라인·전 기기.
class OcrService {
  OcrService._();

  /// 이미지 파일에서 인식한 전체 텍스트(줄바꿈 포함). 실패 시 빈 문자열.
  static Future<String> recognizeFile(String path) async {
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.korean);
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return result.text;
    } catch (_) {
      return '';
    } finally {
      await recognizer?.close();
    }
  }
}
