import 'dart:async';
import 'package:flutter/foundation.dart';
import 'workout_models.dart';
import 'workout_voice.dart';

enum WorkoutPhase { idle, work, rest, done }

/// 실행 중 발화 문구 — 로케일별 문장은 화면(l10n)에서 주입한다.
class WorkoutScript {
  final String Function(String name, int set, int reps) setStart; // 1세트 시작
  final String Function(int set) setStartAgain; // n세트 시작
  final String Function(String name, int dur) timeStart;
  final String Function(String name) freeStart;
  final String lastSetCheer;
  final String halfway;
  final String tenLeft;
  final String Function(int set, int rest) setDoneRest;
  final String Function(String name, int rest) exerciseDoneRest;
  final String Function(String name, String amount) nextExercise;
  final String Function(int set) nextSet;
  final String allDone;
  final String getReady;
  final String Function(int dur) amountTime;
  final String Function(int reps) amountReps;
  final String amountFree;

  const WorkoutScript({
    required this.setStart,
    required this.setStartAgain,
    required this.timeStart,
    required this.freeStart,
    required this.lastSetCheer,
    required this.halfway,
    required this.tenLeft,
    required this.setDoneRest,
    required this.exerciseDoneRest,
    required this.nextExercise,
    required this.nextSet,
    required this.allDone,
    required this.getReady,
    required this.amountTime,
    required this.amountReps,
    required this.amountFree,
  });
}

/// 운동 실행 시퀀서 — reps 구령/버티기 카운트/휴식/예고를 타이머로 진행하고
/// [WorkoutVoice] 로 발화한다. UI 는 ChangeNotifier 를 구독해 그린다.
class WorkoutSession extends ChangeNotifier {
  WorkoutSession({
    required this.voice,
    required this.config,
    required this.script,
    required this.exerciseName,
  });

  final WorkoutVoice voice;
  final WorkoutConfig config;
  final WorkoutScript script;

  /// 운동 → 표시 이름(커스텀 이름 우선, 아니면 libKey 의 l10n).
  final String Function(WorkoutExercise ex) exerciseName;

  List<WorkoutExercise> _routine = const [];
  WorkoutPhase phase = WorkoutPhase.idle;
  int exIdx = 0;
  int set = 1;
  int rep = 0;
  int t = 0;
  int total = 0;
  Timer? _timer;
  Timer? _timer2;

  WorkoutExercise? get current =>
      exIdx < _routine.length ? _routine[exIdx] : null;
  bool get running => phase == WorkoutPhase.work || phase == WorkoutPhase.rest;

  void start(List<WorkoutExercise> routine) {
    if (routine.isEmpty) return;
    _routine = List.of(routine);
    _startWork(0, 1);
  }

  void stop() {
    _clear();
    voice.stop();
    phase = WorkoutPhase.idle;
    exIdx = 0;
    set = 1;
    rep = 0;
    t = 0;
    total = 0;
    notifyListeners();
  }

  /// 현재 세그먼트 건너뛰기 — 휴식이면 다음 작업으로, 작업이면 종료 처리.
  void skip() {
    final ex = current;
    if (ex == null) return;
    _clear();
    if (phase == WorkoutPhase.rest) {
      final exDone = !(ex.type == WorkoutType.reps && set < ex.sets);
      if (exDone) {
        _startWork(exIdx + 1, 1);
      } else {
        _startWork(exIdx, set + 1);
      }
    } else {
      _endSegment(exIdx, ex.type == WorkoutType.reps ? ex.sets : 1);
    }
  }

  void _clear() {
    _timer?.cancel();
    _timer = null;
    _timer2?.cancel();
    _timer2 = null;
  }

  void _startWork(int idx, int newSet) {
    final ex = idx < _routine.length ? _routine[idx] : null;
    if (ex == null) {
      _allDone();
      return;
    }
    final name = exerciseName(ex);
    phase = WorkoutPhase.work;
    exIdx = idx;
    set = newSet;
    rep = 0;
    _clear();

    switch (ex.type) {
      case WorkoutType.reps:
        if (config.saySetAnnounce) {
          voice.say(
            newSet == 1
                ? script.setStart(name, newSet, ex.reps)
                : script.setStartAgain(newSet),
            pri: 1,
          );
        }
        if (newSet == ex.sets && newSet > 1 && config.sayCheer) {
          Timer(const Duration(milliseconds: 1200), () {
            if (phase == WorkoutPhase.work) {
              voice.say(script.lastSetCheer, pri: 4);
            }
          });
        }
        // 세트 총시간(reps×pace) 1초 카운트다운 — 화면 표시만(발화 없음).
        final setDur = (ex.reps * ex.pace).round();
        t = setDur;
        total = setDur;
        _timer = Timer.periodic(
          Duration(milliseconds: (ex.pace * 1000).round()),
          (_) {
            rep++;
            if (config.sayCount) voice.say(voice.countWord(rep), pri: 3);
            if (rep >= ex.reps) {
              _clear();
              notifyListeners();
              Timer(Duration(milliseconds: (ex.pace * 500).round()), () {
                _endSegment(idx, newSet);
              });
              return;
            }
            notifyListeners();
          },
        );
        _timer2 = Timer.periodic(const Duration(seconds: 1), (_) {
          if (t > 0) {
            t--;
            notifyListeners();
          }
          if (t <= 0) {
            _timer2?.cancel();
            _timer2 = null;
          }
        });
      case WorkoutType.time:
        if (config.saySetAnnounce) {
          voice.say(script.timeStart(name, ex.dur), pri: 1);
        }
        t = ex.dur;
        total = ex.dur;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          t--;
          if (t == ex.dur ~/ 2 && t > 5 && config.sayCallout) {
            voice.say(script.halfway, pri: 2);
          } else if (t == 10 && ex.dur > 15 && config.sayCallout) {
            voice.say(script.tenLeft, pri: 2);
          } else if (t <= 3 && t > 0 && config.sayCountdown) {
            voice.say('$t', pri: 1);
          }
          if (t <= 0) {
            _clear();
            _endSegment(idx, 1);
            return;
          }
          notifyListeners();
        });
      case WorkoutType.free:
        if (config.saySetAnnounce) voice.say(script.freeStart(name), pri: 1);
        t = 0;
        total = 0;
        _timer = Timer.periodic(
          Duration(milliseconds: (ex.pace * 1000).round()),
          (_) {
            rep++;
            if (config.sayCount) voice.say(voice.countWord(rep), pri: 3);
            notifyListeners();
          },
        );
    }
    notifyListeners();
  }

  void _endSegment(int idx, int doneSet) {
    final ex = _routine[idx];
    final name = exerciseName(ex);
    final rest = config.restSec;
    final moreSets = ex.type == WorkoutType.reps && doneSet < ex.sets;
    final moreEx = idx < _routine.length - 1;
    if (moreSets) {
      if (config.saySetAnnounce) {
        voice.say(script.setDoneRest(doneSet, rest), pri: 1);
      }
      _startRest(idx, doneSet, exerciseDone: false);
    } else if (moreEx) {
      if (config.saySetAnnounce) {
        voice.say(script.exerciseDoneRest(name, rest), pri: 1);
      }
      _startRest(idx, doneSet, exerciseDone: true);
    } else {
      _allDone();
    }
  }

  void _startRest(int idx, int doneSet, {required bool exerciseDone}) {
    final rest = config.restSec;
    phase = WorkoutPhase.rest;
    exIdx = idx;
    set = doneSet;
    rep = 0;
    t = rest;
    total = rest;
    _clear();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      t--;
      if (t == rest ~/ 2 && config.sayPreview) {
        if (exerciseDone) {
          final nx = idx + 1 < _routine.length ? _routine[idx + 1] : null;
          if (nx != null) {
            final amount = switch (nx.type) {
              WorkoutType.time => script.amountTime(nx.dur),
              WorkoutType.free => script.amountFree,
              WorkoutType.reps => script.amountReps(nx.reps),
            };
            voice.say(
              script.nextExercise(exerciseName(nx), amount),
              pri: 2,
            );
          }
        } else {
          voice.say(script.nextSet(doneSet + 1), pri: 2);
        }
      }
      if (t == 5 && config.sayCountdown) {
        voice.say(script.getReady, pri: 1);
      } else if (t <= 3 && t > 0 && config.sayCountdown) {
        voice.say('$t', pri: 1);
      }
      if (t <= 0) {
        _clear();
        if (exerciseDone) {
          _startWork(idx + 1, 1);
        } else {
          _startWork(idx, doneSet + 1);
        }
        return;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void _allDone() {
    _clear();
    phase = WorkoutPhase.done;
    if (config.saySetAnnounce) voice.say(script.allDone, pri: 1);
    notifyListeners();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }
}
