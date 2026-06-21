import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show AnalogTimerApp;
import '../theme/app_theme.dart';

class _Lang {
  final String label;
  final Locale locale;
  const _Lang(this.label, this.locale);
}

/// 지원 언어 — 네이티브 표기명. (시스템 기본은 별도 항목)
const _languages = <_Lang>[
  _Lang('English', Locale('en')),
  _Lang('한국어', Locale('ko')),
  _Lang('中文 (简体)', Locale('zh')),
  _Lang('中文 (繁體)', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
  _Lang('Español', Locale('es')),
  _Lang('العربية', Locale('ar')),
  _Lang('Português', Locale('pt')),
  _Lang('Français', Locale('fr')),
  _Lang('日本語', Locale('ja')),
  _Lang('Deutsch', Locale('de')),
  _Lang('Русский', Locale('ru')),
  _Lang('हिन्दी', Locale('hi')),
  _Lang('Bahasa Indonesia', Locale('id')),
  _Lang('Italiano', Locale('it')),
  _Lang('Türkçe', Locale('tr')),
];

bool _sameLocale(Locale a, Locale b) =>
    a.languageCode == b.languageCode && a.scriptCode == b.scriptCode;

Future<void> showLanguagePicker(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final active = Localizations.localeOf(context);

  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460, maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                l.language,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  // 시스템 기본 — 수동 선택 해제
                  _LangTile(
                    label: l.languageSystem,
                    selected: false,
                    onTap: () {
                      AnalogTimerApp.setLocale(ctx, null);
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  for (final lang in _languages)
                    _LangTile(
                      label: lang.label,
                      selected: _sameLocale(lang.locale, active),
                      onTap: () {
                        AnalogTimerApp.setLocale(ctx, lang.locale);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LangTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: selected ? AppColors.accent : AppColors.text,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
