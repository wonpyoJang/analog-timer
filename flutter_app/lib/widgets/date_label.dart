/// 날짜·요일 한 줄 라벨. 예: 6/20 (SAT)
///
/// 메인 화면과 데스크톱 오버레이 위젯이 공용으로 쓴다.
const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// [now] 를 'M/D (요일)' 형식 문자열로. weekday: 1=월 … 7=일.
String formatDateLine(DateTime now) =>
    '${now.month}/${now.day} (${_weekdays[now.weekday - 1]})';
