import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/services/deep_link.dart';

void main() {
  group('start', () {
    test('min/sec/label', () {
      final a = parseDeepLink('anytime://start?min=5&sec=30&label=휴식');
      expect(a.kind, DeepLinkKind.start);
      expect(a.min, 5);
      expect(a.sec, 30);
      expect(a.label, '휴식');
      expect(a.totalMs, 330000);
    });
    test('min only', () {
      expect(parseDeepLink('anytime://start?min=5').totalMs, 300000);
    });
    test('no time → totalMs null', () {
      expect(parseDeepLink('anytime://start').totalMs, isNull);
    });
  });

  test('preset/{id}', () {
    final a = parseDeepLink('anytime://preset/focus25');
    expect(a.kind, DeepLinkKind.preset);
    expect(a.id, 'focus25');
  });

  test('loop/{id}?rounds', () {
    final a = parseDeepLink('anytime://loop/focus25?rounds=4');
    expect(a.kind, DeepLinkKind.loop);
    expect(a.id, 'focus25');
    expect(a.rounds, 4);
  });

  test('extend', () {
    final a = parseDeepLink('anytime://extend?min=5');
    expect(a.kind, DeepLinkKind.extend);
    expect(a.min, 5);
  });

  group('stop', () {
    test('bare', () {
      expect(parseDeepLink('anytime://stop').kind, DeepLinkKind.stop);
    });
    test('all=1', () {
      final a = parseDeepLink('anytime://stop?all=1');
      expect(a.kind, DeepLinkKind.stop);
      expect(a.all, true);
    });
  });

  test('ack', () {
    expect(parseDeepLink('anytime://ack').kind, DeepLinkKind.ack);
  });

  test('workout/{id}', () {
    final a = parseDeepLink('anytime://workout/w1');
    expect(a.kind, DeepLinkKind.workout);
    expect(a.id, 'w1');
  });

  test('status', () {
    expect(parseDeepLink('anytime://status').kind, DeepLinkKind.status);
  });

  group('silent 플래그', () {
    test('붙으면 true', () {
      expect(parseDeepLink('anytime://loop/focus25?silent=1').silent, true);
      expect(parseDeepLink('anytime://start?min=5&silent=1').silent, true);
    });
    test('없으면 false', () {
      expect(parseDeepLink('anytime://start?min=5').silent, false);
    });
    test('status 는 silent 미적용(볼 목적)', () {
      // 파싱은 되지만 kind=status. 라우터가 status 는 항상 앱을 연다.
      expect(parseDeepLink('anytime://status').kind, DeepLinkKind.status);
    });
  });

  group('견고성', () {
    test('다른 스킴 → unknown', () {
      expect(parseDeepLink('https://start').kind, DeepLinkKind.unknown);
    });
    test('알 수 없는 명령 → unknown', () {
      expect(parseDeepLink('anytime://frobnicate').kind, DeepLinkKind.unknown);
    });
    test('빈 문자열 → unknown', () {
      expect(parseDeepLink('').kind, DeepLinkKind.unknown);
    });
    test('host 없이 path 로만 온 변형', () {
      final a = parseDeepLink('anytime:///preset/focus25');
      expect(a.kind, DeepLinkKind.preset);
      expect(a.id, 'focus25');
    });
  });
}
