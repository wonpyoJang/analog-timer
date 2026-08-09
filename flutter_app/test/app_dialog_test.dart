import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/widgets/app_dialog.dart';

/// 버튼 라벨로 탭 — AppDialogButton 은 GestureDetector 기반이라 Text 로 찾는다.
Future<void> _tapLabel(WidgetTester t, String label) async {
  await t.tap(find.text(label));
  await t.pumpAndSettle();
}

Widget _host(void Function(BuildContext) onReady) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => onReady(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Confirm — 확인=true / 취소=false', (t) async {
    bool? result;
    await t.pumpWidget(
      _host((c) async {
        result = await showAppConfirm(
          c,
          title: '이 타이머를 지울까요?',
          confirmLabel: '삭제',
          cancelLabel: '취소',
        );
      }),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('이 타이머를 지울까요?'), findsOneWidget);
    await _tapLabel(t, '삭제');
    expect(result, true);

    // 다시 열어 취소 → false
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await _tapLabel(t, '취소');
    expect(result, false);
  });

  testWidgets('Destructive — scrim 탭으로 안 닫힘', (t) async {
    bool? result;
    await t.pumpWidget(
      _host((c) async {
        result = await showAppDestructive(
          c,
          title: '모든 기록을 지울까요?',
          body: '복구할 수 없어요.',
          confirmLabel: '전부 삭제',
          cancelLabel: '취소',
        );
      }),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    // 바깥(scrim) 탭 시도 — 닫히면 안 됨.
    await t.tapAt(const Offset(10, 10));
    await t.pumpAndSettle();
    expect(find.text('모든 기록을 지울까요?'), findsOneWidget);
    expect(result, isNull);
    // 취소로 닫기
    await _tapLabel(t, '취소');
    expect(result, false);
  });

  testWidgets('Choice — 선택 변경 후 확인 시 선택값 반환', (t) async {
    String? picked;
    await t.pumpWidget(
      _host((c) async {
        picked = await showAppChoice<String>(
          c,
          title: '알람 소리',
          selected: 'bell',
          options: const [
            (value: 'bell', label: '부드러운 종', note: '기본'),
            (value: 'beep', label: '디지털 비프', note: null),
            (value: 'vib', label: '진동만', note: null),
          ],
          confirmLabel: '선택',
          cancelLabel: '취소',
        );
      }),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('진동만'));
    await t.pumpAndSettle();
    await _tapLabel(t, '선택');
    expect(picked, 'vib');
  });

  testWidgets('Toast — 메시지·되돌리기 표시 및 undo 콜백', (t) async {
    var undone = false;
    await t.pumpWidget(
      _host((c) {
        showAppToast(
          c,
          '타이머를 지웠어요',
          undoLabel: '되돌리기',
          onUndo: () => undone = true,
        );
      }),
    );
    await t.tap(find.text('open'));
    await t.pump(); // 스낵바 등장 시작
    await t.pump(const Duration(milliseconds: 400)); // 완전히 올라올 때까지
    expect(find.text('타이머를 지웠어요'), findsOneWidget);
    await t.tap(find.text('되돌리기'));
    await t.pump();
    expect(undone, true);
  });

  testWidgets('Stacked — 3개 이상이면 세로 배치(모두 렌더)', (t) async {
    await t.pumpWidget(
      _host((c) {
        showAcknowledge(c, title: 't', okLabel: 'ok');
      }),
    );
    // Stacked 자동 전환은 AppDialog 내부 규칙 — 3버튼 다이얼로그를 직접 구성해 확인.
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDialog(
            title: '지금 루틴을 끝낼까요?',
            actions: const [
              AppAction('계속 진행하기', variant: AppBtn.pri),
              AppAction('여기서 끝내기', variant: AppBtn.gho),
              AppAction('닫기', variant: AppBtn.txt),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('계속 진행하기'), findsOneWidget);
    expect(find.text('여기서 끝내기'), findsOneWidget);
    expect(find.text('닫기'), findsOneWidget);
  });
}
