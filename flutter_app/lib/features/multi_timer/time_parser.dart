/// 한국어 시간 표현 파서(디자인 "온디바이스 & 삼성 API 기획" §4).
///
/// 모델 없이 규칙만으로 한 문장에서 여러 타이머를 뽑는다. 실행 경로에 AI가 없다는
/// 철칙에 따라 정규식·수사 사전으로만 동작 — 오프라인·전 기기·결정론.
/// "라면 사분반, 계란 육분" → [라면 4:30, 계란 6:00].
library;

/// 파서가 대조할 기존 프리셋(이름 매칭이 모델보다 강하다 — §4 초록 콜아웃).
class PresetRef {
  final String name;
  final int totalMs;
  final int? colorValue;
  const PresetRef({required this.name, required this.totalMs, this.colorValue});
}

enum ParsedKind { parsed, preset, unparsed }

/// 해석된 타이머 후보 한 건.
class ParsedTimer {
  final String name;
  final int totalMs; // unparsed 면 0
  final ParsedKind kind;
  final String source; // 원본 조각
  final String? timeExpr; // 찾은 시간 표현("사분반") — 근거 표시용
  final bool rangePickedShort; // "3~4분"에서 짧은 쪽을 골랐는가
  final int? presetColor; // preset 매칭 시 승계 색

  const ParsedTimer({
    required this.name,
    required this.totalMs,
    required this.kind,
    required this.source,
    this.timeExpr,
    this.rangePickedShort = false,
    this.presetColor,
  });
}

/// 한자계 수사 문자 → 값.
const _sino = {
  '일': 1,
  '이': 2,
  '삼': 3,
  '사': 4,
  '오': 5,
  '육': 6,
  '칠': 7,
  '팔': 8,
  '구': 9,
};

/// 고유어 수사(주로 "시간"과 결합) — 긴 것부터 치환해야 부분 매칭 오류가 없다.
const _native = {
  '열두': 12,
  '열한': 11,
  '스물': 20,
  '다섯': 5,
  '여섯': 6,
  '일곱': 7,
  '여덟': 8,
  '아홉': 9,
  '열': 10,
  '한': 1,
  '두': 2,
  '세': 3,
  '네': 4,
};

/// "이십오" → 25, "십오" → 15, "사" → 4. 실패 시 null.
int? _parseSino(String s) {
  var result = 0;
  var current = 0;
  var any = false;
  for (final ch in s.split('')) {
    if (ch == '십') {
      result += (current == 0 ? 1 : current) * 10;
      current = 0;
      any = true;
    } else if (_sino.containsKey(ch)) {
      current = _sino[ch]!;
      any = true;
    } else {
      return null; // 수사 아닌 글자 섞임
    }
  }
  return any ? result + current : null;
}

/// 한글 수사를 아라비아로 정규화. 단위(시간/분/초/시) 앞일 때만 치환해
/// "세탁"의 '세', "사과"의 '사' 같은 일반 단어 오변환을 막는다.
String _normalizeNumbers(String input) {
  var s = input;
  // 한자계 + 단위
  s = s.replaceAllMapped(RegExp(r'([일이삼사오육칠팔구십]+)\s*(시간|분|초|시)'), (m) {
    final n = _parseSino(m.group(1)!);
    return n != null ? '$n${m.group(2)}' : m.group(0)!;
  });
  // 고유어 + 단위 (긴 키 먼저)
  s = s.replaceAllMapped(
    RegExp(r'(열두|열한|스물|다섯|여섯|일곱|여덟|아홉|열|한|두|세|네)\s*(시간|분|초)'),
    (m) => '${_native[m.group(1)]}${m.group(2)}',
  );
  return s;
}

/// 조각에서 총 초를 추출. 시간 표현이 없으면 null.
/// [outExpr]/[outRange] 로 근거 정보를 돌려준다.
int? _extractSeconds(
  String frag, {
  required void Function(String expr) onExpr,
  required void Function() onRange,
}) {
  var total = 0;
  var found = false;
  final exprs = <String>[];

  // 범위 "3~4분" → 짧은 쪽(덜 익은 건 되돌릴 수 있지만 탄 건 못 되돌린다 — §3)
  final range = RegExp(r'(\d+)\s*[~-]\s*(\d+)\s*분').firstMatch(frag);
  if (range != null) {
    final lo = int.parse(range.group(1)!);
    total += lo * 60;
    found = true;
    onRange();
    exprs.add(range.group(0)!);
    onExpr(exprs.join(' '));
    return total;
  }

  // 시간 (+ 반). "반숙"처럼 뒤에 한글이 붙으면 half 가 아니다.
  for (final m in RegExp(r'(\d+)\s*시간(\s*반(?![가-힣]))?').allMatches(frag)) {
    total += int.parse(m.group(1)!) * 3600;
    if (m.group(2) != null) total += 1800;
    found = true;
    exprs.add(m.group(0)!.trim());
  }
  // 분 + 초
  final ms = RegExp(r'(\d+)\s*분\s*(\d+)\s*초').firstMatch(frag);
  if (ms != null) {
    total += int.parse(ms.group(1)!) * 60 + int.parse(ms.group(2)!);
    found = true;
    exprs.add(ms.group(0)!.trim());
  } else {
    // 분 (+ 반). "반숙"처럼 뒤에 한글이 붙으면 half 가 아니다.
    final mm = RegExp(r'(\d+)\s*분(\s*반(?![가-힣]))?').firstMatch(frag);
    if (mm != null) {
      total += int.parse(mm.group(1)!) * 60;
      if (mm.group(2) != null) total += 30;
      found = true;
      exprs.add(mm.group(0)!.trim());
    }
    // 초 단독
    final sec = RegExp(r'(\d+)\s*초').firstMatch(frag);
    if (sec != null && ms == null) {
      total += int.parse(sec.group(1)!);
      found = true;
      exprs.add(sec.group(0)!.trim());
    }
  }
  if (!found) return null;
  onExpr(exprs.join(' '));
  return total;
}

final _splitter = RegExp(r'\s*(?:,|\n|그리고|하고|및|이랑|랑)\s*');
final _particles = RegExp(r'(은|는|이|가|을|를|에|도)$');

/// 시간 표현·수식어를 걷어낸 이름 후보. 앞부분 우선, 없으면 뒷부분.
String _extractName(String frag, String? timeExpr) {
  var s = frag;
  if (timeExpr != null && timeExpr.isNotEmpty) {
    final idx = s.indexOf(timeExpr);
    if (idx >= 0) {
      final before = s.substring(0, idx).trim();
      final after = s.substring(idx + timeExpr.length).trim();
      s = before.isNotEmpty ? before : after;
    }
  }
  // 흔한 후행 수식어 제거
  s = s.replaceAll(RegExp(r'(반숙|완숙|정도|적당히|더|만)$'), '').trim();
  s = s.replaceAll(_particles, '').trim();
  return s;
}

/// 입력 문자열을 타이머 후보 리스트로 파싱한다.
/// 시간 표현이 없으면 [presets] 사전과 대조(1순위), 그래도 없으면 unparsed.
List<ParsedTimer> parseTimers(
  String input, {
  List<PresetRef> presets = const [],
}) {
  final out = <ParsedTimer>[];
  final frags = input
      .split(_splitter)
      .map((f) => f.trim())
      .where((f) => f.isNotEmpty);

  for (final raw in frags) {
    final norm = _normalizeNumbers(raw);
    String? expr;
    var isRange = false;
    final sec = _extractSeconds(
      norm,
      onExpr: (e) => expr = e,
      onRange: () => isRange = true,
    );

    if (sec != null && sec > 0) {
      final name = _extractName(norm, expr);
      // 시간이 있어도 이름이 기존 프리셋과 같으면 색을 승계.
      final pm = _matchPreset(name, presets);
      out.add(
        ParsedTimer(
          name: name.isEmpty ? '' : name,
          totalMs: sec * 1000,
          kind: ParsedKind.parsed,
          source: raw,
          timeExpr: expr,
          rangePickedShort: isRange,
          presetColor: pm?.colorValue,
        ),
      );
      continue;
    }

    // 시간 없음 → 프리셋 사전 대조(§4: 항상 1순위)
    final nameOnly = raw.replaceAll(_particles, '').trim();
    final pm = _matchPreset(nameOnly, presets);
    if (pm != null) {
      out.add(
        ParsedTimer(
          name: pm.name,
          totalMs: pm.totalMs,
          kind: ParsedKind.preset,
          source: raw,
          presetColor: pm.colorValue,
        ),
      );
      continue;
    }

    // 해석 실패 — 버리지 않고 회색 카드로 남긴다(§4 P1: 조용히 사라지면 최악)
    out.add(
      ParsedTimer(
        name: nameOnly,
        totalMs: 0,
        kind: ParsedKind.unparsed,
        source: raw,
      ),
    );
  }
  return out;
}

PresetRef? _matchPreset(String name, List<PresetRef> presets) {
  if (name.isEmpty) return null;
  final n = name.trim();
  for (final p in presets) {
    if (p.name == n) return p;
  }
  // 부분 포함(양방향) — "라면이랑"의 잔여 등
  for (final p in presets) {
    if (n.contains(p.name) || p.name.contains(n)) return p;
  }
  return null;
}
