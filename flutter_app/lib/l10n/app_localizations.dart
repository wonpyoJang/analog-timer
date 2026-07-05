import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ANALOG TIMER'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @timerSection.
  ///
  /// In en, this message translates to:
  /// **'TIMER'**
  String get timerSection;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get btnStart;

  /// No description provided for @btnPause.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get btnPause;

  /// No description provided for @btnResume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get btnResume;

  /// No description provided for @btnRunning.
  ///
  /// In en, this message translates to:
  /// **'RUNNING…'**
  String get btnRunning;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get btnNext;

  /// No description provided for @btnReset.
  ///
  /// In en, this message translates to:
  /// **'RST'**
  String get btnReset;

  /// No description provided for @stopwatchSection.
  ///
  /// In en, this message translates to:
  /// **'STOPWATCH'**
  String get stopwatchSection;

  /// No description provided for @btnLap.
  ///
  /// In en, this message translates to:
  /// **'LAP'**
  String get btnLap;

  /// No description provided for @lapToast.
  ///
  /// In en, this message translates to:
  /// **'Lap {num}    {time}'**
  String lapToast(int num, String time);

  /// No description provided for @timerSegments.
  ///
  /// In en, this message translates to:
  /// **'TIMER SEGMENTS'**
  String get timerSegments;

  /// No description provided for @addSegment.
  ///
  /// In en, this message translates to:
  /// **'+ Add segment'**
  String get addSegment;

  /// No description provided for @loopToggle.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loopToggle;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @segmentColor.
  ///
  /// In en, this message translates to:
  /// **'Segment color'**
  String get segmentColor;

  /// No description provided for @segments.
  ///
  /// In en, this message translates to:
  /// **'Segments'**
  String get segments;

  /// No description provided for @savePresetChip.
  ///
  /// In en, this message translates to:
  /// **'Save current'**
  String get savePresetChip;

  /// No description provided for @presetApplied.
  ///
  /// In en, this message translates to:
  /// **'Preset added · {name}'**
  String presetApplied(String name);

  /// No description provided for @noSegmentsToSave.
  ///
  /// In en, this message translates to:
  /// **'No segments to save'**
  String get noSegmentsToSave;

  /// No description provided for @savePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Save preset'**
  String get savePresetTitle;

  /// No description provided for @presetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Study 50/10'**
  String get presetNameHint;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetName;

  /// No description provided for @presetManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage presets'**
  String get presetManageTitle;

  /// No description provided for @newPreset.
  ///
  /// In en, this message translates to:
  /// **'New preset'**
  String get newPreset;

  /// No description provided for @editPreset.
  ///
  /// In en, this message translates to:
  /// **'Edit preset'**
  String get editPreset;

  /// No description provided for @deletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get deletePresetTitle;

  /// No description provided for @deletePresetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{name}\'?'**
  String deletePresetConfirm(String name);

  /// No description provided for @noPresets.
  ///
  /// In en, this message translates to:
  /// **'No saved presets.\nAdd one with \"New preset\" at the top right.'**
  String get noPresets;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enterName;

  /// No description provided for @atLeastOneSegment.
  ///
  /// In en, this message translates to:
  /// **'Add at least one segment'**
  String get atLeastOneSegment;

  /// No description provided for @legendTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer — inner spiral'**
  String get legendTimer;

  /// No description provided for @legendStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch — outer ring'**
  String get legendStopwatch;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusWaiting;

  /// No description provided for @widget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get widget;

  /// No description provided for @widgetOn.
  ///
  /// In en, this message translates to:
  /// **'Widget ON'**
  String get widgetOn;

  /// No description provided for @notifyTimerDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer complete'**
  String get notifyTimerDoneTitle;

  /// No description provided for @notifyTimerDoneBody.
  ///
  /// In en, this message translates to:
  /// **'All segments finished 🎉'**
  String get notifyTimerDoneBody;

  /// No description provided for @notifySegmentDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Segment complete'**
  String get notifySegmentDoneTitle;

  /// No description provided for @notifySegmentDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{prev} done · Next: {next}'**
  String notifySegmentDoneBody(String prev, String next);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @presetPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro 25/5'**
  String get presetPomodoro;

  /// No description provided for @preset5217.
  ///
  /// In en, this message translates to:
  /// **'52/17'**
  String get preset5217;

  /// No description provided for @presetDeepwork.
  ///
  /// In en, this message translates to:
  /// **'Deep work 90/20'**
  String get presetDeepwork;

  /// No description provided for @segFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get segFocus;

  /// No description provided for @segBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get segBreak;

  /// No description provided for @stopwatchLaps.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch laps'**
  String get stopwatchLaps;

  /// No description provided for @noLaps.
  ///
  /// In en, this message translates to:
  /// **'No laps yet'**
  String get noLaps;

  /// No description provided for @timerLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer log'**
  String get timerLogTitle;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @lapLabel.
  ///
  /// In en, this message translates to:
  /// **'Lap {num}'**
  String lapLabel(int num);

  /// No description provided for @logStart.
  ///
  /// In en, this message translates to:
  /// **'Start: {name}'**
  String logStart(String name);

  /// No description provided for @logPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get logPaused;

  /// No description provided for @logReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get logReset;

  /// No description provided for @logSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {name}'**
  String logSkipped(String name);

  /// No description provided for @logDone.
  ///
  /// In en, this message translates to:
  /// **'Done: {name}'**
  String logDone(String name);

  /// No description provided for @logAllDone.
  ///
  /// In en, this message translates to:
  /// **'All segments done 🎉'**
  String get logAllDone;

  /// No description provided for @logLoop.
  ///
  /// In en, this message translates to:
  /// **'🔁 Loop {count} done'**
  String logLoop(String count);

  /// No description provided for @batteryLow.
  ///
  /// In en, this message translates to:
  /// **'Battery low — please charge'**
  String get batteryLow;

  /// No description provided for @batteryMon.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get batteryMon;

  /// No description provided for @batteryMonOn.
  ///
  /// In en, this message translates to:
  /// **'Battery ON'**
  String get batteryMonOn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery monitoring'**
  String get settingsBattery;

  /// No description provided for @settingsBatteryDesc.
  ///
  /// In en, this message translates to:
  /// **'Warn when battery drops to 20% or below'**
  String get settingsBatteryDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @modeLabelLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get modeLabelLog;

  /// No description provided for @modeLabelToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get modeLabelToday;

  /// No description provided for @modeLabelPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get modeLabelPlan;

  /// No description provided for @dayLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get dayLogTitle;

  /// No description provided for @dayLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded for this day'**
  String get dayLogEmpty;

  /// No description provided for @dayPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Day Plan'**
  String get dayPlanTitle;

  /// No description provided for @dayPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plan set for this day'**
  String get dayPlanEmpty;

  /// No description provided for @planSaveAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Save as plan'**
  String get planSaveAsCurrent;

  /// No description provided for @planLoadIntoTimer.
  ///
  /// In en, this message translates to:
  /// **'Load into timer'**
  String get planLoadIntoTimer;

  /// No description provided for @planSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get planSave;

  /// No description provided for @telemetryConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Help improve Analog Timer'**
  String get telemetryConsentTitle;

  /// No description provided for @telemetryConsentBody.
  ///
  /// In en, this message translates to:
  /// **'If the app closes unexpectedly, anonymous diagnostics (device environment and error logs) are sent to the developer to help find the cause. No personal information or timer content is included. You can turn this off anytime in settings.'**
  String get telemetryConsentBody;

  /// No description provided for @telemetryAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get telemetryAllow;

  /// No description provided for @telemetryDeny.
  ///
  /// In en, this message translates to:
  /// **'Don\'t send'**
  String get telemetryDeny;

  /// No description provided for @telemetryReportSetting.
  ///
  /// In en, this message translates to:
  /// **'Send diagnostics'**
  String get telemetryReportSetting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
