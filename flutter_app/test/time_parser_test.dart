import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/multi_timer/time_parser.dart';

void main() {
  int sec(List<ParsedTimer> r, int i) => r[i].totalMs ~/ 1000;

  group('숫자+단위', () {
    test('4분 30초', () {
      final r = parseTimers('라면 4분 30초');
      expect(r.length, 1);
      expect(sec(r, 0), 270);
      expect(r[0].name, '라면');
      expect(r[0].kind, ParsedKind.parsed);
    });
    test('25분 / 90초', () {
      expect(sec(parseTimers('25분'), 0), 1500);
      expect(sec(parseTimers('90초'), 0), 90);
    });
  });

  group('한글 수사', () {
    test('사분반 → 4:30', () {
      final r = parseTimers('라면 사분반');
      expect(sec(r, 0), 270);
      expect(r[0].name, '라면');
    });
    test('십오분 → 15:00, 이름 뒤에서', () {
      final r = parseTimers('십오분 집중');
      expect(sec(r, 0), 900);
      expect(r[0].name, '집중');
    });
    test('육분 반숙 → 6:00, 이름 계란', () {
      final r = parseTimers('계란 육분 반숙');
      expect(sec(r, 0), 360);
      expect(r[0].name, '계란');
    });
    test('한시간 반 → 1:30:00', () {
      expect(sec(parseTimers('한시간 반'), 0), 5400);
    });
    test('이십오분 → 25:00', () {
      expect(sec(parseTimers('이십오분'), 0), 1500);
    });
  });

  group('구분자 — 여러 타이머', () {
    test('쉼표: 라면 사분반, 계란 육분', () {
      final r = parseTimers('라면 사분반, 계란 육분');
      expect(r.length, 2);
      expect(sec(r, 0), 270);
      expect(r[0].name, '라면');
      expect(sec(r, 1), 360);
      expect(r[1].name, '계란');
    });
    test('파스타 팔분, 소스 오분', () {
      final r = parseTimers('파스타 팔분, 소스 오분');
      expect(sec(r, 0), 480);
      expect(sec(r, 1), 300);
    });
  });

  group('범위 — 짧은 쪽', () {
    test('3~4분 → 3:00', () {
      final r = parseTimers('면 3~4분');
      expect(sec(r, 0), 180);
      expect(r[0].rangePickedShort, true);
    });
  });

  group('프리셋 사전 1순위', () {
    final presets = const [
      PresetRef(name: '라면', totalMs: 270000, colorValue: 111),
      PresetRef(name: '세탁', totalMs: 3300000, colorValue: 222),
    ];
    test('라면이랑 세탁 → 프리셋 2개', () {
      final r = parseTimers('라면이랑 세탁', presets: presets);
      expect(r.length, 2);
      expect(r[0].kind, ParsedKind.preset);
      expect(sec(r, 0), 270);
      expect(r[0].presetColor, 111);
      expect(r[1].kind, ParsedKind.preset);
      expect(sec(r, 1), 3300);
    });
    test('시간 있으면 시간 우선, 색은 프리셋 승계', () {
      final r = parseTimers('라면 3분', presets: presets);
      expect(r[0].kind, ParsedKind.parsed);
      expect(sec(r, 0), 180);
      expect(r[0].presetColor, 111);
    });
  });

  group('해석 실패는 버리지 않는다', () {
    test('적당히 → unparsed 카드로 남김', () {
      final r = parseTimers('라면 사분반, 국물은 적당히');
      expect(r.length, 2);
      expect(r[1].kind, ParsedKind.unparsed);
      expect(r[1].totalMs, 0);
    });
  });

  test('일반 단어 오변환 안 함(세탁의 세)', () {
    final r = parseTimers('세탁 55분');
    expect(r.length, 1);
    expect(sec(r, 0), 3300);
    expect(r[0].name, '세탁');
  });

  group('순차 시작방식 자동 추천(recommendAckGate)', () {
    test('별개 작업(이름 다름) → ack 게이트(확인 후)', () {
      // 파스타/소스 = 단계 사이 손 쓰는 별개 작업
      expect(recommendAckGate(['파스타', '소스']), true);
      expect(recommendAckGate(['면', '계란']), true);
    });
    test('수동 대기 단계(뜸·식히기) → 자동 진행', () {
      expect(recommendAckGate(['면', '뜸 들이기']), false);
      expect(recommendAckGate(['조리', '식히기']), false);
      expect(recommendAckGate(['반죽', '냉장 휴지']), false);
    });
    test('같은 이름 반복 → 자동 진행(연속 과정)', () {
      expect(recommendAckGate(['조리', '조리']), false);
    });
  });
}
