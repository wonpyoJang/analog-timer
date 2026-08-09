import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../services/persistence_service.dart';
import '../../../services/haptic_service.dart';
import '../../../services/sound_service.dart';
import '../../../services/care_service.dart';
import '../../../services/list_display_service.dart';
import '../../../services/overlay_settings_service.dart';
import '../time_parser.dart';
import 'text_timer_screen.dart';
import '../../../services/deep_link.dart';
import '../../../services/deep_link_router.dart';
import '../../../services/shortcuts_service.dart';
import '../../../features/stats/activity_stats_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/desktop_notification_service.dart';
import '../../../overlay/multi_overlay_service.dart';
import '../../../overlay/overlay_coordinator.dart';
import '../bloc/multi_timer_bloc.dart';
import '../bloc/multi_timer_event.dart';
import '../bloc/multi_timer_state.dart';
import '../models/countdown_timer.dart';
import 'alarm_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/ocr_service.dart';
import '../../../services/platform_info.dart';

String _fmt(int ms) {
  final total = (ms / 1000).ceil();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

class MultiTimerScreen extends StatelessWidget {
  /// 하단 탭으로 임베드될 때 true — 뒤로가기 화살표를 숨긴다.
  final bool embedded;
  const MultiTimerScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    // 복원(async)은 _MultiTimerView.initState 에서 dispatch.
    return BlocProvider(
      create: (_) => MultiTimerBloc(),
      child: _MultiTimerView(embedded: embedded),
    );
  }
}

class _MultiTimerView extends StatefulWidget {
  final bool embedded;
  const _MultiTimerView({this.embedded = false});
  @override
  State<_MultiTimerView> createState() => _MultiTimerViewState();
}

class _MultiTimerViewState extends State<_MultiTimerView> {
  Timer? _saveTrailing;
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);
  static const _saveInterval = Duration(milliseconds: 1500);

  // 네이티브 멀티 오버레이 상태 — 사용자가 개별로 띄우기 선택한 타이머 id들.
  final Set<String> _overlayIds = {};
  final Map<String, String> _lastPushed = {};

  /// 원탭 등록용 프리셋 — {'name','durationMs','category'?,'lastUsedMs'?}.
  List<Map<String, dynamic>> _presets = [];

  /// 추가 시트 카테고리 필터(요리 시안 §3): all/cooking/focus/chore.
  String _presetCat = 'all';

  bool _alarmOpen = false;
  Timer? _realarmTimer;
  final Map<String, int> _lastRingMs = {};

  @override
  void initState() {
    super.initState();
    _restore();
    // 단일 오버레이가 켜지면 멀티 오버레이를 전부 닫도록 훅 등록(상호 배타).
    OverlayCoordinator.instance.closeMultiOverlays = _closeAllOverlaysForMutex;
    // l10n 이 필요한 기본 시드는 첫 프레임 후에(initState 에선 inherited 조회 불가).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPresets());
    // pill 탭 = 프리-알림 구간 +5분 연장(페르소나 §5).
    MultiOverlayService.ensureTapListening();
    MultiOverlayService.onPillTap = _onPillTap;
    // 음성 딥링크(§3) — 라우터가 넘긴 대기 액션을 로컬 bloc 으로 소비.
    DeepLinkRouter.instance.pendingMulti.addListener(_onDeepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDeepLink();
      _recoverLostImage(); // 카메라 중 프로세스 종료로 유실된 사진 복구(§3)
    });
  }

  /// 딥링크 대기 액션을 처리한다. 프리셋은 로드 전이면 소비하지 않고
  /// _loadPresets 완료 후 재시도한다(콜드 스타트 대비).
  void _onDeepLink() {
    final a = DeepLinkRouter.instance.pendingMulti.value;
    if (a == null || !mounted) return;
    final bloc = context.read<MultiTimerBloc>();
    final l = AppLocalizations.of(context);
    switch (a.kind) {
      case DeepLinkKind.start:
        final ms = a.totalMs;
        if (ms != null && ms > 0) {
          final name = (a.label != null && a.label!.isNotEmpty)
              ? a.label!
              : l.multiTimerTitle;
          bloc.add(MtAdd(name, ms, autoStart: true));
          _consumeLink();
          _toast(l.voiceStartedTimer(name));
        } else {
          _consumeLink();
        }
      case DeepLinkKind.preset:
        final p = _findPreset(a.id);
        if (p != null) {
          final name = p['name'] as String;
          bloc.add(
            MtAdd(name, (p['durationMs'] as num).toInt(), autoStart: true),
          );
          _markPresetUsed(name);
          _consumeLink();
          _toast(l.voiceStartedTimer(name));
        } else if (_presets.isNotEmpty) {
          _consumeLink(); // 로드됐는데 못 찾음 → 탭만 이동
        }
      case DeepLinkKind.stop:
        _consumeLink();
        final running = bloc.state.timers
            .where((t) => t.running && !t.done)
            .toList();
        if (a.all) {
          for (final t in running) {
            bloc.add(MtPause(t.id));
          }
        } else if (running.length == 1) {
          bloc.add(MtPause(running.first.id));
        } else if (running.length > 1) {
          _toast(l.voiceStopHint); // 추측하지 않는다(§6)
        }
      case DeepLinkKind.extend:
        _consumeLink();
        // 울리는 알람 우선, 없으면 실행 중 — +N분(§3: 확인으로 간주).
        final st = bloc.state.timers;
        final ringing = st.where((t) => t.done && !t.acked).toList();
        final target = ringing.isNotEmpty
            ? ringing.first
            : st.where((t) => t.running).firstOrNull;
        if (target != null) {
          bloc.add(MtExtend(target.id, (a.min ?? 5) * 60000));
          _lastPushed.remove(target.id);
        }
      case DeepLinkKind.ack:
        _consumeLink();
        for (final t in bloc.state.timers.where((t) => t.done && !t.acked)) {
          bloc.add(MtReset(t.id));
        }
      case DeepLinkKind.status:
        _consumeLink(); // 탭 이동만
      default:
        _consumeLink(); // loop/workout 후속
    }
  }

  void _consumeLink() => DeepLinkRouter.instance.pendingMulti.value = null;

  /// 런처 단축어 동기화(§4) — 고정 4종 + 자주 쓰는 프리셋 상위 3.
  /// 이름이 곧 발화 문구/롱프레스 항목. 1글자·숫자만은 오인식 우려로 제외.
  void _syncShortcuts() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final items = <Map<String, String>>[
      {
        'id': 'sc_focus',
        'short': l.scFocus,
        'long': l.scFocus,
        'link':
            'anytime://start?min=25&label=${Uri.encodeQueryComponent(l.scFocus)}',
      },
      {
        'id': 'sc_rest',
        'short': l.scRest,
        'long': l.scRest,
        'link':
            'anytime://start?min=5&label=${Uri.encodeQueryComponent(l.scRest)}',
      },
      {
        'id': 'sc_stop',
        'short': l.scStop,
        'long': l.scStop,
        'link': 'anytime://stop',
      },
      {
        'id': 'sc_status',
        'short': l.scStatus,
        'long': l.scStatus,
        'link': 'anytime://status',
      },
    ];
    final byUse = [..._presets]
      ..sort(
        (a, b) => ((b['lastUsedMs'] as num?)?.toInt() ?? 0).compareTo(
          (a['lastUsedMs'] as num?)?.toInt() ?? 0,
        ),
      );
    var added = 0;
    for (final p in byUse) {
      if (added >= 3) break;
      final name = ((p['name'] as String?) ?? '').trim();
      if (name.length < 2 || RegExp(r'^\d+$').hasMatch(name)) continue;
      items.add({
        'id': 'sc_preset_$added',
        'short': name,
        'long': name,
        'link': 'anytime://preset/${Uri.encodeComponent(name)}',
      });
      added++;
    }
    ShortcutsService.setShortcuts(items);
  }

  Map<String, dynamic>? _findPreset(String? id) {
    if (id == null || id.isEmpty) return null;
    final dec = Uri.decodeComponent(id);
    for (final p in _presets) {
      final n = (p['name'] as String?) ?? '';
      if (n == id || n == dec) return p;
    }
    return null;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<PresetRef> _presetRefs() => [
    for (final p in _presets)
      if (((p['name'] as String?) ?? '').isNotEmpty)
        PresetRef(
          name: p['name'] as String,
          totalMs: (p['durationMs'] as num?)?.toInt() ?? 0,
        ),
  ];

  /// 봉지 OCR(온디바이스 §3) — 촬영/앨범 이미지 → 텍스트 인식 → 시간 파서 →
  /// 시간 표현이 있는 후보만 확인 화면(§C). 못 찾으면 안내 후 휠 폴백(§D).
  Future<void> _ocrFlow(ImageSource source) async {
    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: source, imageQuality: 92);
    } catch (_) {}
    if (file == null) return;
    await _ocrFromPath(file.path);
  }

  /// 카메라로 앱이 백그라운드에서 종료되면 image_picker 결과가 유실된다
  /// (무거운 포그라운드 앱에서 흔함). 복귀 시 retrieveLostData 로 사진을 되찾아
  /// OCR 을 이어간다. 안드로이드 전용. 앱 시작/재개 시 1회 확인.
  Future<void> _recoverLostImage() async {
    if (!isAndroid) return;
    try {
      final lost = await ImagePicker().retrieveLostData();
      final f = lost.file;
      if (lost.isEmpty || f == null) return;
      // 멀티 탭으로 전환 후 복구한 사진으로 OCR 진행.
      DeepLinkRouter.instance.requestedTab.value = DeepLinkRouter.tabMulti;
      await _ocrFromPath(f.path);
    } catch (_) {}
  }

  /// 이미지 경로 → OCR → 파싱 → 확인 화면(촬영/앨범/유실복구 공통).
  Future<void> _ocrFromPath(String path) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final bloc = context.read<MultiTimerBloc>();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l.ocrReading),
        duration: const Duration(seconds: 1),
      ),
    );
    final text = await OcrService.recognizeFile(path);
    if (!mounted) return;
    // §3: 숫자가 아니라 시간 표현만 취한다 — unparsed(단위 없는 550ml 등)는 버림.
    final found = parseTimers(
      text,
      presets: _presetRefs(),
    ).where((t) => t.kind != ParsedKind.unparsed).toList();
    if (found.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.ocrNoTime)));
      return;
    }
    navigator.push(
      MaterialPageRoute(
        builder: (_) => TextTimerScreen(
          presets: _presetRefs(),
          bloc: bloc,
          initial: found,
          title: l.ocrTitle,
        ),
      ),
    );
  }

  /// 촬영/앨범 선택 시트(§B "앨범" 버튼 겸용).
  void _startOcr() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                l.ocrCamera,
                style: const TextStyle(color: AppColors.text),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _ocrFlow(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                l.ocrAlbum,
                style: const TextStyle(color: AppColors.text),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _ocrFlow(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onPillTap(String id) {
    if (!mounted) return;
    final bloc = context.read<MultiTimerBloc>();
    final t = bloc.state.timers.where((x) => x.id == id).firstOrNull;
    if (t == null || !t.running) return;
    final preMs = CareService.instance.preAlarmMin.value * 60000;
    if (preMs <= 0 || t.remainMs > preMs) return; // 프리-알림 구간에서만 연장
    HapticService.instance.light();
    _extend(bloc, id);
  }

  /// +5분 연장 — pill 은 deadline 자체 틱이라 push key 를 무효화해 새 deadline 을
  /// 강제 재전송한다(안 하면 리스트만 늘고 pill 은 옛 deadline 으로 계속 감).
  void _extend(MultiTimerBloc bloc, String id) {
    bloc.add(MtExtend(id, 5 * 60000));
    _lastPushed.remove(id);
  }

  /// 저장된 프리셋 로드 — 없으면 기본 4종 시드. 요리 팩(§3)은 1회 병합 시드.
  Future<void> _loadPresets() async {
    var loaded = await PersistenceService.loadMultiTimerPresets();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    loaded ??= [
      {
        'name': l.multiTimerPresetStudy,
        'durationMs': 25 * 60000,
        'category': 'focus',
      },
      {
        'name': l.multiTimerPresetDeskCleanup,
        'durationMs': 10 * 60000,
        'category': 'chore',
      },
      {
        'name': l.multiTimerPresetRest,
        'durationMs': 5 * 60000,
        'category': 'focus',
      },
      {
        'name': l.multiTimerPresetBrushTeeth,
        'durationMs': 3 * 60000,
        'category': 'chore',
      },
    ];
    // 요리 팩 — 기존 사용자에게도 1회만 추가(플래그 항목으로 마킹).
    final seeded = loaded.any((p) => p['cookpack'] == true);
    if (!seeded) {
      loaded.addAll([
        {
          'name': l.cookRamen,
          'durationMs': 270000,
          'category': 'cooking',
          'cookpack': true,
        },
        {
          'name': l.cookPasta,
          'durationMs': 480000,
          'category': 'cooking',
          'cookpack': true,
        },
        {
          'name': l.cookEgg,
          'durationMs': 390000,
          'category': 'cooking',
          'cookpack': true,
        },
        {
          'name': l.cookSauce,
          'durationMs': 720000,
          'category': 'cooking',
          'cookpack': true,
        },
        {
          'name': l.cookRice,
          'durationMs': 1800000,
          'category': 'cooking',
          'cookpack': true,
        },
      ]);
      await PersistenceService.saveMultiTimerPresets(loaded);
    }
    if (mounted) setState(() => _presets = loaded ?? []);
    // 프리셋 로드 후 대기 중인 preset 딥링크 재시도(콜드 스타트).
    _onDeepLink();
    _syncShortcuts();
  }

  /// 최근 사용이 항상 첫 칩(§3) — lastUsedMs 내림차순, 없는 항목은 원래 순서.
  List<Map<String, dynamic>> _visiblePresets() {
    final list = _presets.where((p) {
      if (_presetCat == 'all') return true;
      return (p['category'] as String?) == _presetCat;
    }).toList();
    list.sort((a, b) {
      final la = (a['lastUsedMs'] as num?)?.toInt() ?? 0;
      final lb = (b['lastUsedMs'] as num?)?.toInt() ?? 0;
      return lb.compareTo(la);
    });
    return list;
  }

  void _markPresetUsed(String name) {
    final idx = _presets.indexWhere((p) => p['name'] == name);
    if (idx < 0) return;
    _presets[idx] = {
      ..._presets[idx],
      'lastUsedMs': DateTime.now().millisecondsSinceEpoch,
    };
    PersistenceService.saveMultiTimerPresets(_presets);
    _syncShortcuts(); // 사용 빈도 변화 → 동적 단축어 갱신
  }

  /// 상호 배타 — 단일 오버레이 활성화 시 호출돼 멀티 오버레이를 전부 닫는다.
  Future<void> _closeAllOverlaysForMutex() async {
    if (_overlayIds.isEmpty) return;
    await MultiOverlayService.closeAll();
    _lastPushed.clear();
    if (mounted) setState(() => _overlayIds.clear());
  }

  Future<void> _restore() async {
    final data = await PersistenceService.loadMultiTimerState();
    if (data == null || !mounted) return;
    final rawList = (data['timers'] as List?) ?? const [];
    final savedAt = (data['savedAtMs'] as num?)?.toInt();
    final elapsed = savedAt == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - savedAt;
    final timers = rawList
        .map((e) => CountdownTimer.fromJson(e as Map<String, dynamic>))
        .map((t) {
          // 앱 꺼진 동안 running 이었으면 경과분 차감.
          if (t.running && elapsed > 0) {
            final r = t.remainMs - elapsed;
            if (r <= 0) {
              return t.copyWith(remainMs: 0, running: false, done: true);
            }
            return t.copyWith(remainMs: r);
          }
          return t;
        })
        .toList();
    if (mounted) context.read<MultiTimerBloc>().add(MtRestore(timers));
  }

  // 스로틀 저장 — 실행 중 매 틱 저장(16ms)은 막되, 최소 1.5s 간격으로 갱신하고
  // 마지막 상태를 트레일링 저장(디바운스는 틱마다 리셋돼 영영 저장 안 되는 버그가 있어 사용 안 함).
  void _save(MultiTimerState s) {
    _lastSave = DateTime.now();
    PersistenceService.saveMultiTimerState(
      s.timers.map((t) => t.toJson()).toList(),
    );
  }

  void _persist(MultiTimerState s) {
    final since = DateTime.now().difference(_lastSave);
    if (since >= _saveInterval) {
      _saveTrailing?.cancel();
      _save(s);
    } else {
      _saveTrailing?.cancel();
      _saveTrailing = Timer(_saveInterval - since, () => _save(s));
    }
  }

  /// 잔여 60s(햅틱)·30s/10s(경고음) 경계 하향 크로스 감지 — 스펙 카드 5.
  final Map<String, int> _prevRemain = {};
  void _onWarnThresholds(MultiTimerState s) {
    final preMin = CareService.instance.preAlarmMin.value;
    for (final t in s.timers) {
      final prev = _prevRemain[t.id];
      if (t.running && prev != null) {
        final preMs = preMin * 60000;
        if (preMin > 0 && prev > preMs && t.remainMs <= preMs) {
          _showPreAlarmBanner(t, preMin);
        }
        if (prev > 60000 && t.remainMs <= 60000) {
          HapticService.instance.impact(); // mediumImpact ×1
        }
        if ((prev > 30000 && t.remainMs <= 30000) ||
            (prev > 10000 && t.remainMs <= 10000)) {
          SoundService.instance.play('warn');
        }
      }
      _prevRemain[t.id] = t.remainMs;
    }
    _prevRemain.removeWhere((id, _) => !s.timers.any((t) => t.id == id));
  }

  /// 프리-알림 배너 — 소리·진동 없음(몰입 유지). +5분 연장 액션 제공(페르소나 §5).
  void _showPreAlarmBanner(CountdownTimer t, int preMin) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(l.preAlarmBanner(t.name, preMin)),
        action: SnackBarAction(
          label: l.preAlarmExtend,
          textColor: AppColors.accent,
          onPressed: () => _extend(bloc, t.id),
        ),
      ),
    );
  }

  /// 미확인 완료가 있는 동안 재알림(§5) — 간격은 카테고리별(알람 시안 §1:
  /// 요리 1분 / 집안일 5분 / 그 외 2분). 확인/연장 시 자동 중단.
  void _syncRealarm(MultiTimerState s) {
    final hasRinging = s.timers.any((t) => t.done && !t.acked);
    if (hasRinging &&
        _realarmTimer == null &&
        CareService.instance.realarm.value) {
      _realarmTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (!mounted) return;
        final st = context.read<MultiTimerBloc>().state;
        final ringing = st.timers.where((t) => t.done && !t.acked).toList();
        if (ringing.isEmpty) {
          _realarmTimer?.cancel();
          _realarmTimer = null;
          _lastRingMs.clear();
          return;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        final l = AppLocalizations.of(context);
        for (final t in ringing) {
          final ivMs =
              CareService.instance.realarmIntervalMin(t.category) * 60000;
          final last = _lastRingMs[t.id] ?? t.doneAtMs;
          if (now - last < ivMs) continue;
          _lastRingMs[t.id] = now;
          SoundService.instance.play('done');
          HapticService.instance.heavy();
          if (CareService.instance.ttsName.value) {
            final over = ((now - t.doneAtMs) / 60000).round();
            TtsService.instance.speak(
              l.ttsOverdue(t.name, over),
              localeTag: Localizations.localeOf(context).toLanguageTag(),
            );
          }
        }
      });
    } else if (!hasRinging) {
      _realarmTimer?.cancel();
      _realarmTimer = null;
      _lastRingMs.clear();
    }
  }

  /// 루프 전환 통지(루프 시안 §4) — 회차 시작(첫 단계 진입)은 강하게,
  /// 그 외 단계 전환은 가볍게. 전부 자동 진행이라 확인은 불필요.
  void _onLooped(BuildContext context, MultiTimerState s) {
    if (s.justLooped.isEmpty) return;
    final l = AppLocalizations.of(context);
    for (final id in s.justLooped) {
      final t = s.timers.where((x) => x.id == id).firstOrNull;
      if (t == null || !t.isLoop) continue;
      final step = t.loopSteps[t.loopStepIdx];
      final newRound = t.loopStepIdx == 0;
      if (newRound) {
        SoundService.instance.play('done');
        HapticService.instance.heavy();
      } else {
        SoundService.instance.play('start');
        HapticService.instance.light();
      }
      final msg = newRound
          ? l.loopRoundStart(t.loopRound, step.name)
          : l.loopStepStart(step.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: const Duration(seconds: 3), content: Text(msg)),
      );
      if (CareService.instance.ttsName.value) {
        TtsService.instance.speak(
          msg,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        );
      }
    }
  }

  void _openAlarm() {
    if (_alarmOpen || !mounted) return;
    _alarmOpen = true;
    final bloc = context.read<MultiTimerBloc>();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => AlarmScreen(bloc: bloc),
          ),
        )
        .whenComplete(() => _alarmOpen = false);
  }

  void _onCompleted(BuildContext context, MultiTimerState s) {
    final ids = s.justCompleted;
    if (ids.isEmpty) return;
    // 활동 통계 집계 — 완료된 타이머의 이름·계획시간 기록.
    for (final id in ids) {
      final t = s.timers.where((x) => x.id == id).firstOrNull;
      if (t != null) {
        ActivityStatsService.instance.log(t.name, t.totalMs);
      }
    }
    _openAlarm(); // 풀스크린 알람(요리 시안 §1)
    HapticService.instance.heavy(); // 스펙: 완료 = heavyImpact (동시 다건도 1회)
    SoundService.instance.play('done'); // C5-E5-G5 아르페지오(알람 본음과 별개)
    final l = AppLocalizations.of(context);
    if (ids.length == 1) {
      final t = s.timers.firstWhere(
        (x) => x.id == ids.first,
        orElse: () => CountdownTimer(name: '', totalMs: 0),
      );
      final doneMsg = switch (CareService.instance.messageTone.value) {
        'warm' => l.doneMsgWarm(t.name),
        'brief' => l.doneMsgBrief(t.name),
        _ => l.doneMsgNeutral(t.name),
      };
      DesktopNotificationService.notify(l.multiTimerTitle, doneMsg);
      if (t.name.isNotEmpty && CareService.instance.ttsName.value) {
        TtsService.instance.speak(
          doneMsg,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        );
      }
    } else {
      final msg = l.multiTimerAllDone(ids.length);
      DesktopNotificationService.notify(l.multiTimerTitle, msg);
      TtsService.instance.speak(
        msg,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
      );
    }
  }

  /// 개별 타이머의 오버레이 위젯 켜기/끄기. 켤 때만 권한 확인.
  Future<void> _toggleOverlayFor(
    BuildContext context,
    CountdownTimer timer,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<MultiTimerBloc>();
    if (_overlayIds.contains(timer.id)) {
      MultiOverlayService.close(timer.id);
      _lastPushed.remove(timer.id);
      if (mounted) setState(() => _overlayIds.remove(timer.id));
      return;
    }
    // 상한 초과 방지 — 기기 화면의 겹침 없는 슬롯 수만큼 허용.
    final maxWindows = await MultiOverlayService.maxWindows();
    if (_overlayIds.length >= maxWindows) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.multiTimerOverlayLimit(maxWindows))),
      );
      return;
    }
    if (!await MultiOverlayService.isPermissionGranted) {
      await MultiOverlayService.requestPermission();
      if (!await MultiOverlayService.isPermissionGranted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.multiTimerOverlayPermission)),
        );
        return;
      }
    }
    if (!mounted) return;
    // 상호 배타 — 단일 오버레이(2nd 엔진)를 꺼 플랫폼 스레드 경합 제거.
    unawaited(OverlayCoordinator.instance.onMultiOverlayEnabled());
    setState(() => _overlayIds.add(timer.id));
    _syncOverlays(l, bloc.state);
  }

  /// 선택된 타이머(_overlayIds)만 네이티브 오버레이 창에 반영. 표시 문구가 바뀐
  /// 창만 push(초 단위 throttle), 삭제됐거나 선택 해제된 타이머의 창은 닫는다.
  void _syncOverlays(AppLocalizations l, MultiTimerState state) {
    final byId = {for (final t in state.timers) t.id: t};
    // 목록에서 사라진 선택 항목은 정리.
    final gone = _overlayIds.where((id) => !byId.containsKey(id)).toList();
    for (final id in gone) {
      MultiOverlayService.close(id);
      _overlayIds.remove(id);
      _lastPushed.remove(id);
    }
    for (var i = 0; i < state.timers.length; i++) {
      final t = state.timers[i];
      if (!_overlayIds.contains(t.id)) continue;
      // 끝나면 자동 숨기기(§D) — 완료·확인된 pill 은 닫는다.
      if (OverlaySettingsService.instance.autoHideDone.value &&
          t.done &&
          t.acked) {
        MultiOverlayService.close(t.id);
        _overlayIds.remove(t.id);
        _lastPushed.remove(t.id);
        continue;
      }
      final color = AppColors.segColors[i % AppColors.segColors.length]
          .toARGB32();
      // 상태 전이(시작/정지/리셋/완료/이름·지속시간 변경) 시에만 push. 매초 남은시간은
      // 네이티브가 자체 계산하므로 key 에 remainMs/시간 문자열을 넣지 않는다.
      final key = '${t.name}|${t.running}|${t.done}|${t.totalMs}';
      if (_lastPushed[t.id] == key) continue;
      _lastPushed[t.id] = key;
      MultiOverlayService.show(
        id: t.id,
        name: t.name,
        colorValue: color,
        totalMs: t.totalMs,
        remainMs: t.remainMs,
        running: t.running,
        done: t.done,
        doneText: l.multiTimerDone,
      );
    }
  }

  @override
  void dispose() {
    _realarmTimer?.cancel();
    _saveTrailing?.cancel();
    DeepLinkRouter.instance.pendingMulti.removeListener(_onDeepLink);
    if (identical(
      OverlayCoordinator.instance.closeMultiOverlays,
      _closeAllOverlaysForMutex,
    )) {
      OverlayCoordinator.instance.closeMultiOverlays = null;
    }
    // 화면을 떠나면 bloc(ticker)이 정지 → 멈춘 pill이 남지 않도록 정리.
    if (_overlayIds.isNotEmpty) MultiOverlayService.closeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.text,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          l.multiTimerTitle,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocConsumer<MultiTimerBloc, MultiTimerState>(
        listener: (context, state) {
          _persist(state);
          _onCompleted(context, state);
          _onLooped(context, state);
          _onWarnThresholds(state);
          _syncRealarm(state);
          _syncOverlays(l, state);
        },
        builder: (context, state) {
          if (state.timers.isEmpty) {
            return Center(
              child: Text(
                l.multiTimerEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            );
          }
          final lds = ListDisplayService.instance;
          // 색상은 원래(추가) 순서에 고정 — 정렬해도 타이머별 색이 유지되게.
          final colorById = <String, Color>{
            for (var i = 0; i < state.timers.length; i++)
              state.timers[i].id:
                  AppColors.segColors[i % AppColors.segColors.length],
          };
          return AnimatedBuilder(
            animation: Listenable.merge([
              lds.showRing,
              lds.density,
              lds.sortMode,
              lds.keepDoneMin,
              lds.dimDone,
            ]),
            builder: (context, _) {
              // 완료 유지 시간(§E) — 지난 완료 타이머는 리스트에서 숨김(상태 유지).
              final now = DateTime.now().millisecondsSinceEpoch;
              final keepMs = lds.keepDoneMin.value * 60000;
              final items = state.timers.where((t) {
                if (!t.done) return true;
                if (lds.keepDoneMin.value == 0) return false;
                if (t.doneAtMs <= 0) return true;
                return now - t.doneAtMs < keepMs;
              }).toList();
              if (lds.sortMode.value == 'remain') {
                items.sort((a, b) {
                  if (a.done != b.done) return a.done ? 1 : -1;
                  return a.remainMs.compareTo(b.remainMs);
                });
              }
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    l.multiTimerEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border,
                ),
                itemBuilder: (context, i) => _TimerRow(
                  timer: items[i],
                  color: colorById[items[i].id] ?? AppColors.segColors[0],
                  overlayOn: _overlayIds.contains(items[i].id),
                  onToggleOverlay: MultiOverlayService.supported
                      ? () => _toggleOverlayFor(context, items[i])
                      : null,
                  scale: lds.scale,
                  showRing: lds.showRing.value,
                  dim: lds.dimDone.value && items[i].done,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController();
    Duration picked = const Duration(minutes: 3);
    var editMode = false;
    var pickerKey = 0; // 편집 모드에서 칩 탭 시 피커를 새 값으로 재생성
    var loopMode = false; // 루프 프리셋 만들기(루프 시안 §2)
    final loopSteps = <LoopStep>[];
    var loopRepeat = 4;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // 링 채움 = 최장 프리셋 대비 듀레이션 비율(디자인 시안).
          final maxMs = _presets.fold<int>(
            1,
            (m, p) => ((p['durationMs'] as num?)?.toInt() ?? 0) > m
                ? (p['durationMs'] as num).toInt()
                : m,
          );
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 10,
            ),
            // 루프 모드 등으로 내용이 길어지면 스크롤(오버플로 방지).
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editMode ? l.multiTimerPresetEdit : l.multiTimerAdd,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_presets.isNotEmpty || editMode)
                        TextButton(
                          onPressed: () =>
                              setSheetState(() => editMode = !editMode),
                          child: Text(
                            editMode
                                ? l.multiTimerEditDone
                                : l.multiTimerPresetEdit,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 카테고리 필터(요리 시안 §3) — 데이터만 추가, 구조 변화 없음.
                  if (_presets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final c in {
                              'all': l.catAll,
                              'cooking': l.catCooking,
                              'focus': l.catFocus,
                              'chore': l.catChore,
                            }.entries)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(c.value),
                                  selected: _presetCat == c.key,
                                  onSelected: (_) {
                                    setState(() => _presetCat = c.key);
                                    setSheetState(() {});
                                  },
                                  selectedColor: AppColors.accent.withAlpha(
                                    0x24,
                                  ),
                                  backgroundColor: const Color(0xFF232326),
                                  labelStyle: TextStyle(
                                    color: _presetCat == c.key
                                        ? AppColors.accent
                                        : AppColors.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  side: BorderSide(
                                    color: _presetCat == c.key
                                        ? AppColors.accent
                                        : AppColors.border,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  // 프리셋 칩 2열 그리드 — 탭: 등록+시작 / 편집 모드: 입력란 복사·✕ 삭제.
                  if (_presets.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 0, bottom: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // 큰 글꼴(시스템×앱 텍스트 스케일)에서도 안 넘치게 여유.
                            mainAxisExtent: 76,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _visiblePresets().length,
                      itemBuilder: (_, i) {
                        final p = _visiblePresets()[i];
                        final name = p['name'] as String? ?? '';
                        final ms = (p['durationMs'] as num?)?.toInt() ?? 0;
                        final recent =
                            i == 0 && (p['lastUsedMs'] as num?) != null;
                        final ringColor =
                            AppColors.segColors[i % AppColors.segColors.length];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: const Color(0xFF232326),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (ms <= 0) return;
                                  if (editMode) {
                                    // 편집 모드: 이름·시간을 입력란으로 복사.
                                    nameCtrl.text = name;
                                    picked = Duration(milliseconds: ms);
                                    setSheetState(() => pickerKey++);
                                    return;
                                  }
                                  SoundService.instance.play('tap');
                                  HapticService.instance.light();
                                  _markPresetUsed(name);
                                  final rawSteps = p['steps'] as List?;
                                  if (rawSteps != null && rawSteps.isNotEmpty) {
                                    bloc.add(
                                      MtAddLoop(
                                        name,
                                        rawSteps
                                            .map(
                                              (e) => LoopStep.fromJson(
                                                Map<String, dynamic>.from(e),
                                              ),
                                            )
                                            .toList(),
                                        (p['repeat'] as num?)?.toInt() ?? 1,
                                      ),
                                    );
                                  } else {
                                    bloc.add(
                                      MtAdd(
                                        name,
                                        ms,
                                        autoStart: true,
                                        category: p['category'] as String?,
                                      ),
                                    );
                                  }
                                  Navigator.pop(ctx);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l.multiTimerPresetStarted(
                                          '$name ${_fmt(ms)}',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      CustomPaint(
                                        size: const Size(34, 34),
                                        painter: _PresetRingPainter(
                                          color: ringColor,
                                          frac: (ms / maxMs).clamp(0.05, 1.0),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: AppColors.text,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (recent) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.accent
                                                          .withAlpha(0x1F),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      l.presetRecent,
                                                      style: const TextStyle(
                                                        color: AppColors.accent,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _fmt(ms),
                                              style: TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (editMode)
                              Positioned(
                                top: -7,
                                right: -7,
                                child: GestureDetector(
                                  onTap: () async {
                                    _presets.removeAt(i);
                                    await PersistenceService.saveMultiTimerPresets(
                                      _presets,
                                    );
                                    setSheetState(() {});
                                    if (mounted) setState(() {});
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l.multiTimerPresetDeleted,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  if (editMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l.multiTimerPresetEditHint,
                        style: TextStyle(color: AppColors.faint, fontSize: 13),
                      ),
                    ),
                  // 봉지·안내문 찍기(온디바이스 §3·§A) — OCR 로 조리시간 인식(Android).
                  if (!editMode && isAndroid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: const Color(0xFF141416),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(ctx);
                            _startOcr();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withAlpha(0x24),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.document_scanner_outlined,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.ocrEntry,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l.ocrEntryDesc,
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.faint,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 말·글로 타이머 만들기(온디바이스 §4·§E) — 한 문장에서 여러 개.
                  if (!editMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: const Color(0xFF141416),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(ctx);
                            final refs = [
                              for (final p in _presets)
                                if (((p['name'] as String?) ?? '').isNotEmpty)
                                  PresetRef(
                                    name: p['name'] as String,
                                    totalMs:
                                        (p['durationMs'] as num?)?.toInt() ?? 0,
                                  ),
                            ];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TextTimerScreen(presets: refs, bloc: bloc),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withAlpha(0x24),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_voice_outlined,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.textTimerEntry,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l.textTimerEntryDesc,
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.faint,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 루프 모드(루프 시안 §2) — 단계 리스트 + 반복 횟수.
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.loopToggle,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l.loopToggleDesc,
                              style: TextStyle(
                                color: AppColors.faint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: loopMode,
                        activeThumbColor: AppColors.accent,
                        onChanged: (v) => setSheetState(() => loopMode = v),
                      ),
                    ],
                  ),
                  if (loopMode) ...[
                    for (var si = 0; si < loopSteps.length; si++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232326),
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors
                                    .segColors[si % AppColors.segColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loopSteps[si].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _fmt(loopSteps[si].ms),
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () =>
                                  setSheetState(() => loopSteps.removeAt(si)),
                              child: Icon(
                                Icons.close,
                                size: 17,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (loopSteps.length < 4)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final ms = picked.inMilliseconds;
                            if (ms <= 0) return;
                            final nm = nameCtrl.text.trim().isEmpty
                                ? l.multiTimerTitle
                                : nameCtrl.text.trim();
                            setSheetState(() {
                              loopSteps.add(LoopStep(nm, ms));
                              nameCtrl.clear();
                            });
                          },
                          child: Text(
                            l.loopAddStep,
                            style: TextStyle(
                              color: AppColors.faint,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.loopRepeat,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: AppColors.muted),
                              onPressed: () => setSheetState(
                                () =>
                                    loopRepeat = (loopRepeat - 1).clamp(1, 12),
                              ),
                            ),
                            Text(
                              '× $loopRepeat',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: AppColors.muted),
                              onPressed: () => setSheetState(
                                () =>
                                    loopRepeat = (loopRepeat + 1).clamp(1, 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.loopTotal,
                          style: TextStyle(
                            color: AppColors.faint,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _fmt(
                            loopSteps.fold<int>(0, (a, e) => a + e.ms) *
                                loopRepeat,
                          ),
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: l.multiTimerNameHint,
                      hintStyle: TextStyle(color: AppColors.muted),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: CupertinoTimerPicker(
                      key: ValueKey(pickerKey),
                      mode: CupertinoTimerPickerMode.hms,
                      initialTimerDuration: picked,
                      onTimerDurationChanged: (d) => picked = d,
                    ),
                  ),
                  Opacity(
                    opacity: editMode ? 0.4 : 1.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              Icons.star_border,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            label: Text(
                              l.multiTimerPresetSave,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: editMode
                                ? null
                                : () async {
                                    final ms = picked.inMilliseconds;
                                    if (ms <= 0) return;
                                    final name = nameCtrl.text.trim().isEmpty
                                        ? l.multiTimerTitle
                                        : nameCtrl.text.trim();
                                    // 같은 이름이 있으면 시간만 갱신(중복 칩 방지).
                                    final idx = _presets.indexWhere(
                                      (p) => p['name'] == name,
                                    );
                                    final entry = {
                                      'name': name,
                                      'durationMs': ms,
                                    };
                                    if (idx >= 0) {
                                      _presets[idx] = entry;
                                    } else {
                                      _presets.add(entry);
                                    }
                                    await PersistenceService.saveMultiTimerPresets(
                                      _presets,
                                    );
                                    setSheetState(() {});
                                    if (mounted) setState(() {});
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l.multiTimerPresetSaved),
                                      ),
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: editMode
                                ? null
                                : () {
                                    if (loopMode) {
                                      if (loopSteps.isEmpty) return;
                                      final name = nameCtrl.text.trim().isEmpty
                                          ? loopSteps.first.name
                                          : nameCtrl.text.trim();
                                      // 프리셋으로 저장(steps/repeat) + 즉시 시작.
                                      _presets.add({
                                        'name': name,
                                        'durationMs':
                                            loopSteps.fold<int>(
                                              0,
                                              (a, e) => a + e.ms,
                                            ) *
                                            loopRepeat,
                                        'steps': loopSteps
                                            .map((e) => e.toJson())
                                            .toList(),
                                        'repeat': loopRepeat,
                                      });
                                      PersistenceService.saveMultiTimerPresets(
                                        _presets,
                                      );
                                      SoundService.instance.play('add');
                                      bloc.add(
                                        MtAddLoop(
                                          name,
                                          List.of(loopSteps),
                                          loopRepeat,
                                        ),
                                      );
                                      Navigator.pop(ctx);
                                      return;
                                    }
                                    final ms = picked.inMilliseconds;
                                    if (ms <= 0) return;
                                    final name = nameCtrl.text.trim().isEmpty
                                        ? l.multiTimerTitle
                                        : nameCtrl.text.trim();
                                    SoundService.instance.play('add');
                                    bloc.add(MtAdd(name, ms));
                                    Navigator.pop(ctx);
                                  },
                            child: Text(
                              loopMode ? l.loopSaveStart : l.multiTimerAdd,
                              style: const TextStyle(
                                color: Color(0xFF141416),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 남은시간 표시 — running 이면 콜론이 1초 주기로 점멸(스펙 3, 러닝 인지 보조).
/// 자체 타이머 없이 bloc 250ms 틱 리빌드 시각으로 위상을 계산한다.
class _TimeText extends StatelessWidget {
  final String text;
  final Color color;
  final bool blink;
  final double scale;
  const _TimeText({
    required this.text,
    required this.color,
    this.blink = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontSize: 26 * scale,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    if (!blink) return Text(text, style: style);
    final dim = DateTime.now().millisecondsSinceEpoch % 1000 >= 500;
    final colonColor = dim ? color.withAlpha(0x8C) : color;
    return Text.rich(
      TextSpan(
        children: [
          for (final ch in text.characters)
            TextSpan(
              text: ch,
              style: ch == ':' ? style.copyWith(color: colonColor) : style,
            ),
        ],
      ),
    );
  }
}

/// 프리셋 칩의 색 링 — 듀레이션 비율만큼 시계방향으로 채움(디자인 시안 cring).
class _PresetRingPainter extends CustomPainter {
  final Color color;
  final double frac;
  const _PresetRingPainter({required this.color, required this.frac});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.border;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(r, 0, 6.2832, false, base);
    canvas.drawArc(r, -1.5708, 6.2832 * frac, false, fill);
  }

  @override
  bool shouldRepaint(_PresetRingPainter old) =>
      old.color != color || old.frac != frac;
}

class _TimerRow extends StatelessWidget {
  final CountdownTimer timer;
  final Color color;
  final bool overlayOn;
  final VoidCallback? onToggleOverlay;
  final double scale;
  final bool showRing;
  final bool dim;
  const _TimerRow({
    required this.timer,
    required this.color,
    this.overlayOn = false,
    this.onToggleOverlay,
    this.scale = 1.0,
    this.showRing = false,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    // 상태 문법: ringing(완료·미확인, 요리 시안 §4) > done > running > paused > idle.
    final ringing = timer.done && !timer.acked;
    final paused =
        !timer.running && !timer.done && timer.remainMs < timer.totalMs;
    final idle = !timer.running && !timer.done && !paused;
    final frac = timer.totalMs <= 0
        ? 0.0
        : (1 - timer.remainMs / timer.totalMs).clamp(0.0, 1.0);

    final tagLabel = ringing
        ? l.alarmRinging
        : timer.done
        ? l.multiTimerDone
        : timer.isLoop && timer.running
        ? l.loopStepTag(
            timer.loopSteps[timer.loopStepIdx].name,
            timer.loopRound,
            timer.loopRepeat,
          )
        : paused
        ? l.multiTimerStatePaused
        : idle
        ? l.multiTimerStateIdle
        : null;
    final tagColor = ringing
        ? AppColors.danger
        : timer.done
        ? AppColors.swGreen
        : timer.isLoop && timer.running
        ? AppColors.timerOrange
        : paused
        ? AppColors.accent
        : AppColors.faint;
    final tagBg = ringing
        ? AppColors.danger.withAlpha(0x24)
        : timer.done
        ? AppColors.swGreen.withAlpha(0x24)
        : timer.isLoop && timer.running
        ? AppColors.timerOrange.withAlpha(0x24)
        : paused
        ? AppColors.accent.withAlpha(0x1F)
        : AppColors.border.withAlpha(0x66);

    final timeColor = ringing
        ? AppColors.danger
        : timer.done
        ? AppColors.swGreen
        : timer.running
        ? AppColors.text
        : AppColors.muted;
    final playColor = ringing
        ? AppColors.danger
        : timer.done
        ? AppColors.swGreen
        : AppColors.accent;

    // 등장 모션(스펙 2): translateY 18→0 + fade + scale .97→1, 380ms easeOutCubic.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: Transform.scale(scale: 0.97 + 0.03 * t, child: child),
        ),
      ),
      // 일시정지 페이드(스펙 4): 밝기(투명도)로 상태 전환 — 색맹 안전.
      child: AnimatedOpacity(
        opacity: (paused ? 0.55 : 1.0) * (dim ? 0.5 : 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          color: ringing
              ? AppColors.danger.withAlpha(0x0F)
              : timer.done
              ? AppColors.swGreen.withAlpha(0x0D)
              : null,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12 * scale, 16, 16 * scale),
                child: Row(
                  children: [
                    // 진행 링(§E) — 켜면 남은 비율을 링으로, 끄면 상태 점.
                    if (showRing)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(
                          painter: _PresetRingPainter(
                            color: timer.done ? AppColors.swGreen : color,
                            frac: timer.done ? 1.0 : frac,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: timer.done ? AppColors.swGreen : color,
                          shape: BoxShape.circle,
                          boxShadow: timer.running
                              ? [
                                  BoxShadow(
                                    color: color.withAlpha(0x40),
                                    spreadRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (timer.done) ...[
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.swGreen,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  timer.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: timer.running
                                        ? AppColors.text
                                        : AppColors.muted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (tagLabel != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tagLabel,
                                    style: TextStyle(
                                      color: tagColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          _TimeText(
                            text: timer.done ? '00:00' : _fmt(timer.remainMs),
                            color: timeColor,
                            blink: timer.running,
                            scale: scale,
                          ),
                        ],
                      ),
                    ),
                    // 주 액션(재생/일시정지/완료 후 리셋)만 원형 배경으로 강조.
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Material(
                        color: playColor.withAlpha(0x24),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            HapticService.instance.selection();
                            if (timer.done) {
                              bloc.add(MtReset(timer.id));
                            } else if (timer.running) {
                              SoundService.instance.play('pause');
                              bloc.add(MtPause(timer.id));
                            } else {
                              SoundService.instance.play('start');
                              bloc.add(MtStart(timer.id));
                            }
                          },
                          child: Icon(
                            timer.done
                                ? Icons.replay
                                : timer.running
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: playColor,
                            semanticLabel: timer.done
                                ? l.btnReset
                                : timer.running
                                ? l.btnPause
                                : l.btnStart,
                          ),
                        ),
                      ),
                    ),
                    if (!timer.done)
                      IconButton(
                        icon: Icon(Icons.replay, color: AppColors.muted),
                        tooltip: l.btnReset,
                        onPressed: () => bloc.add(MtReset(timer.id)),
                      ),
                    if (onToggleOverlay != null)
                      IconButton(
                        icon: Icon(
                          overlayOn
                              ? Icons.picture_in_picture
                              : Icons.picture_in_picture_outlined,
                          color: overlayOn ? AppColors.accent : AppColors.muted,
                        ),
                        tooltip: overlayOn
                            ? l.multiTimerOverlayOff
                            : l.multiTimerOverlayOn,
                        onPressed: onToggleOverlay,
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.muted),
                      tooltip: l.delete,
                      onPressed: () {
                        SoundService.instance.play('del');
                        bloc.add(MtRemove(timer.id));
                      },
                    ),
                  ],
                ),
              ),
              // 하단 진행바(스펙 3) — 등장·갱신 600ms easeOutCubic 보간.
              if (!idle)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 3,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: timer.done ? 1.0 : frac),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          backgroundColor: AppColors.border.withAlpha(0x80),
                          valueColor: AlwaysStoppedAnimation(
                            timer.done
                                ? AppColors.swGreen
                                : timer.running
                                ? color
                                : const Color(0xFF4A4A4E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
