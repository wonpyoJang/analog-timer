import 'package:intl/intl.dart';

/// 날짜·요일 한 줄 라벨. 예: 6/20 (Sat) / 6/20 (토) / 6/20 (土)
///
/// 요일 약자는 [localeName](언어 코드)에 따라 현지화된다.
/// 메인 화면과 데스크톱 오버레이 위젯이 공용으로 쓴다.
String formatDateLine(DateTime now, String localeName) =>
    DateFormat('M/d (EEE)', localeName).format(now);
