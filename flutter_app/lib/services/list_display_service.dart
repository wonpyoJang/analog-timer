import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 멀티 타이머 리스트 표시 설정(디자인 "설정 상세 페이지" §E).
///
/// 전부 view-only — 타이머 상태(bloc)는 건드리지 않고 리스트 렌더만 바꾼다.
/// 진행 링 표시·카드 밀도·정렬·완료 유지 시간·완료 흐리게.
class ListDisplayService {
  ListDisplayService._();
  static final ListDisplayService instance = ListDisplayService._();

  static const _kShowRing = 'list_show_ring';
  static const _kDensity = 'list_density'; // 0 촘촘 · 1 보통 · 2 크게
  static const _kSort = 'list_sort'; // 'remain' | 'created'
  static const _kKeepMin = 'list_keep_done_min'; // 0=바로 숨김
  static const _kDimDone = 'list_dim_done';

  final ValueNotifier<bool> showRing = ValueNotifier<bool>(true);
  final ValueNotifier<int> density = ValueNotifier<int>(1);
  final ValueNotifier<String> sortMode = ValueNotifier<String>('remain');
  final ValueNotifier<int> keepDoneMin = ValueNotifier<int>(30);
  final ValueNotifier<bool> dimDone = ValueNotifier<bool>(false);

  /// 카드 밀도 → 세로 여백·글자 배율.
  double get scale => switch (density.value) {
    0 => 0.82,
    2 => 1.18,
    _ => 1.0,
  };

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      showRing.value = p.getBool(_kShowRing) ?? true;
      density.value = p.getInt(_kDensity) ?? 1;
      sortMode.value = p.getString(_kSort) ?? 'remain';
      keepDoneMin.value = p.getInt(_kKeepMin) ?? 30;
      dimDone.value = p.getBool(_kDimDone) ?? false;
    } catch (_) {}
  }

  Future<void> setShowRing(bool v) async {
    showRing.value = v;
    await _putBool(_kShowRing, v);
  }

  Future<void> setDensity(int v) async {
    density.value = v;
    await _putInt(_kDensity, v);
  }

  Future<void> setSortMode(String v) async {
    sortMode.value = v;
    await _putString(_kSort, v);
  }

  Future<void> setKeepDoneMin(int v) async {
    keepDoneMin.value = v;
    await _putInt(_kKeepMin, v);
  }

  Future<void> setDimDone(bool v) async {
    dimDone.value = v;
    await _putBool(_kDimDone, v);
  }

  Future<void> _putBool(String k, bool v) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(k, v);
    } catch (_) {}
  }

  Future<void> _putInt(String k, int v) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(k, v);
    } catch (_) {}
  }

  Future<void> _putString(String k, String v) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(k, v);
    } catch (_) {}
  }
}
