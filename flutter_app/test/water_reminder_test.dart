import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/services/water_reminder_service.dart';

// 활동창 7:00(420)–22:30(1350) 기준.
int _ms(int h, int m) => DateTime(2026, 8, 10, h, m).millisecondsSinceEpoch;
const _start = 420, _end = 1350;

void main() {
  group('nextWaterReminderMs — 간격', () {
    test('마지막 섭취 + 간격', () {
      final next = nextWaterReminderMs(
        nowMs: _ms(10, 5),
        lastDrankMs: _ms(10, 0),
        intervalMin: 60,
        fixedTimes: const [],
        activeStartMin: _start,
        activeEndMin: _end,
      );
      expect(next, _ms(11, 0)); // 10:00 + 1h
    });

    test('마셨어요가 늦어지면 다음도 늦어짐(리셋)', () {
      final a = nextWaterReminderMs(
        nowMs: _ms(10, 30),
        lastDrankMs: _ms(10, 0),
        intervalMin: 60,
        fixedTimes: const [],
        activeStartMin: _start,
        activeEndMin: _end,
      );
      final b = nextWaterReminderMs(
        nowMs: _ms(10, 30),
        lastDrankMs: _ms(10, 20),
        intervalMin: 60,
        fixedTimes: const [],
        activeStartMin: _start,
        activeEndMin: _end,
      );
      expect(a, _ms(11, 0));
      expect(b, _ms(11, 20)); // 20분 늦게 마셨으니 20분 늦게
    });
  });

  group('nextWaterReminderMs — 정해진 시각', () {
    test('정해진 시각이 간격보다 이르면 정해진 시각 채택', () {
      final next = nextWaterReminderMs(
        nowMs: _ms(10, 0),
        lastDrankMs: _ms(9, 30), // 간격 후보 11:30 (interval 120)
        intervalMin: 120,
        fixedTimes: const [540, 660, 840], // 9·11·14시 → now 이후 첫 11:00
        activeStartMin: _start,
        activeEndMin: _end,
      );
      expect(next, _ms(11, 0)); // 11:00 < 11:30
    });
    test('간격이 정해진 시각보다 이르면 간격 채택', () {
      final next = nextWaterReminderMs(
        nowMs: _ms(10, 0),
        lastDrankMs: _ms(9, 40), // 간격 10:40
        intervalMin: 60,
        fixedTimes: const [660], // 11:00
        activeStartMin: _start,
        activeEndMin: _end,
      );
      expect(next, _ms(10, 40)); // 더 이른 간격
    });
  });

  group('nextWaterReminderMs — 활동 시간대', () {
    test('활동창 끝 이후 후보 → 다음날 활동 시작', () {
      final next = nextWaterReminderMs(
        nowMs: _ms(22, 20),
        lastDrankMs: _ms(22, 20), // 간격 23:20 (활동창 밖)
        intervalMin: 60,
        fixedTimes: const [],
        activeStartMin: _start,
        activeEndMin: _end,
      );
      expect(next, DateTime(2026, 8, 11, 7, 0).millisecondsSinceEpoch);
    });
    test('활동창 시작 전 후보 → 오늘 활동 시작으로 당김', () {
      final next = nextWaterReminderMs(
        nowMs: _ms(6, 0),
        lastDrankMs: _ms(6, 0), // 간격 7:00 정각(경계) 유지
        intervalMin: 30,
        fixedTimes: const [],
        activeStartMin: _start,
        activeEndMin: _end,
      );
      // 6:30 은 활동창 밖 → 7:00 로 당김
      expect(next, _ms(7, 0));
    });
  });
}
