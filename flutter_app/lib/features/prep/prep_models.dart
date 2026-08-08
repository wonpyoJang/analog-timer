/// 준비물 체크리스트(디자인 "준비물 체크리스트") — 목록/항목 모델.
class PrepItem {
  final String id;
  String text;
  bool done;
  PrepItem({required this.id, required this.text, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};

  static PrepItem fromJson(Map<String, dynamic> j) => PrepItem(
    id: j['id'] as String? ?? 'i${DateTime.now().microsecondsSinceEpoch}',
    text: j['text'] as String? ?? '',
    done: j['done'] as bool? ?? false,
  );
}

class PrepList {
  final String id;
  String name;
  String icon;

  /// true = 매일 아침 자동 리셋 대상. false(🌙) = 수동 리셋(여행 등 일회성).
  bool daily;
  List<PrepItem> items;

  PrepList({
    required this.id,
    required this.name,
    required this.icon,
    this.daily = true,
    List<PrepItem>? items,
  }) : items = items ?? [];

  int get doneCount => items.where((i) => i.done).length;
  bool get allDone => items.isNotEmpty && doneCount == items.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'daily': daily,
    'items': items.map((e) => e.toJson()).toList(),
  };

  static PrepList fromJson(Map<String, dynamic> j) => PrepList(
    id: j['id'] as String? ?? 'l${DateTime.now().microsecondsSinceEpoch}',
    name: j['name'] as String? ?? '',
    icon: j['icon'] as String? ?? '🎒',
    daily: j['daily'] as bool? ?? true,
    items: ((j['items'] as List?) ?? const [])
        .map((e) => PrepItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

const prepIcons = ['🎒', '🏠', '💊', '🏊', '✈️', '💼', '🏋️', '📚', '🌙', '🔑'];

/// 첫 실행 시드(시안) — 로케일별 텍스트.
List<PrepList> prepSeed(bool ko) {
  var n = 0;
  String nid() => 's${DateTime.now().microsecondsSinceEpoch}_${n++}';
  PrepList mk(
    String name,
    String icon,
    List<String> items, {
    bool daily = true,
  }) => PrepList(
    id: nid(),
    name: name,
    icon: icon,
    daily: daily,
    items: [for (final t in items) PrepItem(id: nid(), text: t)],
  );
  if (ko) {
    return [
      mk('외출 전', '🔑', ['지갑', '열쇠', '폰', '이어폰', '교통카드']),
      mk('등교/출근', '💼', ['노트북', '충전기', '사원증', '텀블러', '우산 (비 오면)']),
      mk('약', '💊', ['아침 약', '비타민']),
      mk('가방 싸기 (전날 밤)', '🌙', [
        '내일 입을 옷',
        '도시락',
        '충전기',
        '과제/서류',
      ], daily: false),
      mk('수영장', '🏊', ['수영복', '수경', '수모', '수건', '샴푸'], daily: false),
    ];
  }
  return [
    mk('Before leaving', '🔑', [
      'Wallet',
      'Keys',
      'Phone',
      'Earbuds',
      'Transit card',
    ]),
    mk('School/Work', '💼', [
      'Laptop',
      'Charger',
      'Badge',
      'Tumbler',
      'Umbrella (if rain)',
    ]),
    mk('Meds', '💊', ['Morning meds', 'Vitamins']),
    mk('Pack bag (night before)', '🌙', [
      'Tomorrow\'s clothes',
      'Lunchbox',
      'Charger',
      'Homework/papers',
    ], daily: false),
    mk('Swimming', '🏊', [
      'Swimsuit',
      'Goggles',
      'Cap',
      'Towel',
      'Shampoo',
    ], daily: false),
  ];
}
