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

  /// No description provided for @widgetIosHint.
  ///
  /// In en, this message translates to:
  /// **'The timer floats over other apps — leave the app to see it'**
  String get widgetIosHint;

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

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navMulti.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get navMulti;

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

  /// No description provided for @settingsTelemetryDesc.
  ///
  /// In en, this message translates to:
  /// **'Send anonymous diagnostics & ANR info (no personal data)'**
  String get settingsTelemetryDesc;

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

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackEntry.
  ///
  /// In en, this message translates to:
  /// **'Send feedback to the developer'**
  String get feedbackEntry;

  /// No description provided for @feedbackEntryDesc.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or request a feature (photos/videos welcome)'**
  String get feedbackEntryDesc;

  /// No description provided for @feedbackCategoryBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedbackCategoryBug;

  /// No description provided for @feedbackCategoryFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature request'**
  String get feedbackCategoryFeature;

  /// No description provided for @feedbackCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackCategoryOther;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug or the feature you\'d like…'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackContactHint.
  ///
  /// In en, this message translates to:
  /// **'Contact (optional — email etc. for follow-up)'**
  String get feedbackContactHint;

  /// No description provided for @feedbackAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get feedbackAttachPhoto;

  /// No description provided for @feedbackAttachVideo.
  ///
  /// In en, this message translates to:
  /// **'Attach video'**
  String get feedbackAttachVideo;

  /// No description provided for @feedbackRecordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record voice'**
  String get feedbackRecordVoice;

  /// No description provided for @feedbackRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording… tap to stop'**
  String get feedbackRecording;

  /// No description provided for @feedbackMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable — check permission in system settings'**
  String get feedbackMicDenied;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback has been sent.'**
  String get feedbackSent;

  /// No description provided for @feedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send — check your network and try again'**
  String get feedbackFailed;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a message first'**
  String get feedbackMessageRequired;

  /// No description provided for @feedbackIncludeLogs.
  ///
  /// In en, this message translates to:
  /// **'Include diagnostic logs (device info & recent actions — no personal data)'**
  String get feedbackIncludeLogs;

  /// No description provided for @reviewPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Analog Timer?'**
  String get reviewPromptTitle;

  /// No description provided for @reviewPromptBody.
  ///
  /// In en, this message translates to:
  /// **'You just finished a session — nice work! 🎉\nIf you have a moment, tell the developer what you like or what could be better. It really helps.'**
  String get reviewPromptBody;

  /// No description provided for @reviewPromptAccept.
  ///
  /// In en, this message translates to:
  /// **'Share thoughts'**
  String get reviewPromptAccept;

  /// No description provided for @reviewPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get reviewPromptLater;

  /// No description provided for @reviewPromptNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get reviewPromptNever;

  /// No description provided for @syncPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Device pairing'**
  String get syncPageTitle;

  /// No description provided for @syncConnected.
  ///
  /// In en, this message translates to:
  /// **'✓ Connected'**
  String get syncConnected;

  /// No description provided for @syncRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room: {id}'**
  String syncRoomLabel(String id);

  /// No description provided for @syncRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Timer, presets, and settings are shared across every device in this room.'**
  String get syncRoomDesc;

  /// No description provided for @syncAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Add another device'**
  String get syncAddDevice;

  /// No description provided for @syncInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite from this device'**
  String get syncInviteTitle;

  /// No description provided for @syncInviteDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR or enter the 6-digit code on the other device.'**
  String get syncInviteDesc;

  /// No description provided for @syncCreateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate invite code'**
  String get syncCreateCode;

  /// No description provided for @syncJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get syncJoinTitle;

  /// No description provided for @syncJoinDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code shown on the other device.'**
  String get syncJoinDesc;

  /// No description provided for @syncJoinBtn.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get syncJoinBtn;

  /// No description provided for @syncDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get syncDisconnect;

  /// No description provided for @syncExpiry.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter within 5 minutes'**
  String get syncExpiry;

  /// No description provided for @syncErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get a code — check your network'**
  String get syncErrorNetwork;

  /// No description provided for @syncErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong or expired code'**
  String get syncErrorCode;

  /// No description provided for @syncErrorCodeLen.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get syncErrorCodeLen;

  /// No description provided for @syncScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get syncScanQr;

  /// No description provided for @syncScanCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get syncScanCancel;

  /// No description provided for @tipWidgetToggle.
  ///
  /// In en, this message translates to:
  /// **'Show or hide the floating widget'**
  String get tipWidgetToggle;

  /// No description provided for @tipWidgetRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh the widget (use if it is frozen or missing)'**
  String get tipWidgetRefresh;

  /// No description provided for @tipAppRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to fix a frozen screen — records and elapsed time are kept'**
  String get tipAppRestart;

  /// No description provided for @tipOverlayOpacity.
  ///
  /// In en, this message translates to:
  /// **'Adjust widget transparency'**
  String get tipOverlayOpacity;

  /// No description provided for @tipOverlayResize.
  ///
  /// In en, this message translates to:
  /// **'Drag to resize the widget'**
  String get tipOverlayResize;

  /// No description provided for @tipOverlayHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the widget'**
  String get tipOverlayHide;

  /// No description provided for @tipStopwatchToggle.
  ///
  /// In en, this message translates to:
  /// **'Start or stop the stopwatch'**
  String get tipStopwatchToggle;

  /// No description provided for @settingsTts.
  ///
  /// In en, this message translates to:
  /// **'Voice announcements'**
  String get settingsTts;

  /// No description provided for @settingsTtsDesc.
  ///
  /// In en, this message translates to:
  /// **'Speak segment changes and timer completion aloud'**
  String get settingsTtsDesc;

  /// No description provided for @settingsTtsSample.
  ///
  /// In en, this message translates to:
  /// **'Voice announcements are on'**
  String get settingsTtsSample;

  /// No description provided for @ttsOnboardBody.
  ///
  /// In en, this message translates to:
  /// **'Segment changes like this can also be announced by voice'**
  String get ttsOnboardBody;

  /// No description provided for @ttsOnboardEnable.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get ttsOnboardEnable;

  /// No description provided for @ttsVoiceMissingHint.
  ///
  /// In en, this message translates to:
  /// **'For natural announcements, add your language\'s voice in Windows Settings > Time & Language > Speech'**
  String get ttsVoiceMissingHint;

  /// No description provided for @menuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// No description provided for @menuSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Language · notifications · battery'**
  String get menuSettingsHint;

  /// No description provided for @menuTroubleshoot.
  ///
  /// In en, this message translates to:
  /// **'TROUBLESHOOT'**
  String get menuTroubleshoot;

  /// No description provided for @menuAutoRecoveryNote.
  ///
  /// In en, this message translates to:
  /// **'Auto detection and recovery is on — you rarely need these.'**
  String get menuAutoRecoveryNote;

  /// No description provided for @shortcutSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutSheetTitle;

  /// No description provided for @shortcutGlobalSection.
  ///
  /// In en, this message translates to:
  /// **'Anywhere (global)'**
  String get shortcutGlobalSection;

  /// No description provided for @shortcutInAppSection.
  ///
  /// In en, this message translates to:
  /// **'When this window is focused'**
  String get shortcutInAppSection;

  /// No description provided for @shortcutTimerToggle.
  ///
  /// In en, this message translates to:
  /// **'Start / pause timer'**
  String get shortcutTimerToggle;

  /// No description provided for @shortcutTimerNext.
  ///
  /// In en, this message translates to:
  /// **'Next segment'**
  String get shortcutTimerNext;

  /// No description provided for @shortcutSwToggle.
  ///
  /// In en, this message translates to:
  /// **'Start / stop stopwatch'**
  String get shortcutSwToggle;

  /// No description provided for @shortcutSwLap.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get shortcutSwLap;

  /// No description provided for @shortcutWidgetToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle widget'**
  String get shortcutWidgetToggle;

  /// No description provided for @shortcutMultiTimer.
  ///
  /// In en, this message translates to:
  /// **'Open multiple timers'**
  String get shortcutMultiTimer;

  /// No description provided for @shortcutWidgetMove.
  ///
  /// In en, this message translates to:
  /// **'Move widget (click the widget first)'**
  String get shortcutWidgetMove;

  /// No description provided for @shortcutWidgetAnchor.
  ///
  /// In en, this message translates to:
  /// **'Snap widget to 3×3 grid'**
  String get shortcutWidgetAnchor;

  /// No description provided for @shortcutWidgetMirror.
  ///
  /// In en, this message translates to:
  /// **'Flip widget to opposite side'**
  String get shortcutWidgetMirror;

  /// No description provided for @shortcutWidgetFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus widget (start keyboard placement)'**
  String get shortcutWidgetFocus;

  /// No description provided for @shortcutWidgetBlur.
  ///
  /// In en, this message translates to:
  /// **'Return to previous app'**
  String get shortcutWidgetBlur;

  /// No description provided for @keysHintTimerToggle.
  ///
  /// In en, this message translates to:
  /// **'Tip: Space or Ctrl+Alt+Space also starts/pauses the timer'**
  String get keysHintTimerToggle;

  /// No description provided for @keysHintTimerNext.
  ///
  /// In en, this message translates to:
  /// **'Tip: N or Ctrl+Alt+N also skips to the next segment'**
  String get keysHintTimerNext;

  /// No description provided for @keysHintSwToggle.
  ///
  /// In en, this message translates to:
  /// **'Tip: the S key also starts/stops the stopwatch'**
  String get keysHintSwToggle;

  /// No description provided for @keysHintSwLap.
  ///
  /// In en, this message translates to:
  /// **'Tip: L or Ctrl+Alt+L also records a lap'**
  String get keysHintSwLap;

  /// No description provided for @menuShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get menuShortcuts;

  /// No description provided for @settingsHotkeys.
  ///
  /// In en, this message translates to:
  /// **'Global shortcuts'**
  String get settingsHotkeys;

  /// No description provided for @settingsHotkeysDesc.
  ///
  /// In en, this message translates to:
  /// **'Work from any app. Tap an item below to change its keys. In-app: Space, N, S, L, W'**
  String get settingsHotkeysDesc;

  /// No description provided for @hotkeyReset.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get hotkeyReset;

  /// No description provided for @hotkeyRecordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Press the new key combination'**
  String get hotkeyRecordPrompt;

  /// No description provided for @hotkeyNeedModifier.
  ///
  /// In en, this message translates to:
  /// **'Almost — hold Ctrl, Alt or Win together with {key}'**
  String hotkeyNeedModifier(String key);

  /// No description provided for @hotkeyDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already used by \"{action}\"'**
  String hotkeyDuplicate(String action);

  /// No description provided for @hotkeyNow.
  ///
  /// In en, this message translates to:
  /// **'now: {combo}'**
  String hotkeyNow(String combo);

  /// No description provided for @hotkeyTakenWarning.
  ///
  /// In en, this message translates to:
  /// **'Taken by another app — tap to change'**
  String get hotkeyTakenWarning;

  /// No description provided for @hotkeyRecordCaution.
  ///
  /// In en, this message translates to:
  /// **'Other apps lose this combo while shortcuts are on'**
  String get hotkeyRecordCaution;

  /// No description provided for @settingsTtsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice style'**
  String get settingsTtsVoice;

  /// No description provided for @settingsTtsVoiceDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsTtsVoiceDefault;

  /// No description provided for @settingsTtsVoicePreview.
  ///
  /// In en, this message translates to:
  /// **'This is how announcements will sound'**
  String get settingsTtsVoicePreview;

  /// No description provided for @menuRefreshWidget.
  ///
  /// In en, this message translates to:
  /// **'Refresh widget'**
  String get menuRefreshWidget;

  /// No description provided for @menuRestartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart app'**
  String get menuRestartApp;

  /// No description provided for @trayShow.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get trayShow;

  /// No description provided for @trayMulti.
  ///
  /// In en, this message translates to:
  /// **'Multi-timer'**
  String get trayMulti;

  /// No description provided for @trayRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart (unfreeze)'**
  String get trayRestart;

  /// No description provided for @trayQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get trayQuit;

  /// No description provided for @menuErrorReports.
  ///
  /// In en, this message translates to:
  /// **'Error reports'**
  String get menuErrorReports;

  /// No description provided for @overlayLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the clock, then tap a dot to move it there'**
  String get overlayLongPressHint;

  /// No description provided for @editCoachGrid.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to jump there'**
  String get editCoachGrid;

  /// No description provided for @editCoachDpad.
  ///
  /// In en, this message translates to:
  /// **'Arrows for fine-tuning · hold to repeat'**
  String get editCoachDpad;

  /// No description provided for @editCoachControls.
  ///
  /// In en, this message translates to:
  /// **'⤢ Size · ⇄ Switch side · ✓ Done'**
  String get editCoachControls;

  /// No description provided for @editCoachDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to start'**
  String get editCoachDismiss;

  /// No description provided for @overlayKbGuide1.
  ///
  /// In en, this message translates to:
  /// **'←↑→↓ move · Shift = bigger'**
  String get overlayKbGuide1;

  /// No description provided for @overlayKbGuide2.
  ///
  /// In en, this message translates to:
  /// **'1–9 snap · Tab mirror · Esc done'**
  String get overlayKbGuide2;

  /// No description provided for @overlayKbHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: move with keyboard — {combo}'**
  String overlayKbHint(String combo);

  /// No description provided for @hotkeyRecordGuide1.
  ///
  /// In en, this message translates to:
  /// **'Hold Ctrl or Alt first, then tap a letter — like {example}.'**
  String hotkeyRecordGuide1(String example);

  /// No description provided for @hotkeyRecordGuide2.
  ///
  /// In en, this message translates to:
  /// **'Pick one you don\'t already use elsewhere — adding Shift makes clashes rare.'**
  String get hotkeyRecordGuide2;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeXLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textSizeXLarge;

  /// No description provided for @textSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Timer 25:00 preview'**
  String get textSizePreview;

  /// No description provided for @a11yClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get a11yClose;

  /// No description provided for @a11yEditSegment.
  ///
  /// In en, this message translates to:
  /// **'Edit segment'**
  String get a11yEditSegment;

  /// No description provided for @a11yDismissBanner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get a11yDismissBanner;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on start, pause and completion'**
  String get settingsHapticsDesc;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Toast when a segment changes or the timer completes'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsColorblind.
  ///
  /// In en, this message translates to:
  /// **'Colorblind mode'**
  String get settingsColorblind;

  /// No description provided for @settingsColorblindDesc.
  ///
  /// In en, this message translates to:
  /// **'Distinguish stopwatch by dashed pattern, not just color'**
  String get settingsColorblindDesc;

  /// No description provided for @settingsHourlyChime.
  ///
  /// In en, this message translates to:
  /// **'Hourly time announcement'**
  String get settingsHourlyChime;

  /// No description provided for @settingsHourlyChimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Speaks the time on the hour · quiet 10 PM–8 AM'**
  String get settingsHourlyChimeDesc;

  /// No description provided for @hourlyChimeSpoken.
  ///
  /// In en, this message translates to:
  /// **'It\'s {time}'**
  String hourlyChimeSpoken(String time);

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsHighContrastDesc.
  ///
  /// In en, this message translates to:
  /// **'Brighten secondary text for easier reading'**
  String get settingsHighContrastDesc;

  /// No description provided for @waterWidgetOnboardBody.
  ///
  /// In en, this message translates to:
  /// **'Keep cups and the next reminder always on screen with the floating water widget'**
  String get waterWidgetOnboardBody;

  /// No description provided for @waterWidgetOnboardEnable.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get waterWidgetOnboardEnable;

  /// No description provided for @waterDesktopWidget.
  ///
  /// In en, this message translates to:
  /// **'Floating water widget'**
  String get waterDesktopWidget;

  /// No description provided for @waterDesktopWidgetSub.
  ///
  /// In en, this message translates to:
  /// **'Cups and next reminder in an always-on-top mini window'**
  String get waterDesktopWidgetSub;

  /// No description provided for @multiTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Multiple timers'**
  String get multiTimerTitle;

  /// No description provided for @multiTimerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add timer'**
  String get multiTimerAdd;

  /// No description provided for @multiTimerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Timer name'**
  String get multiTimerNameHint;

  /// No description provided for @multiTimerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No timers yet. Tap + to add one.'**
  String get multiTimerEmpty;

  /// No description provided for @multiTimerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get multiTimerDone;

  /// No description provided for @multiTimerOverlayOn.
  ///
  /// In en, this message translates to:
  /// **'Show overlays'**
  String get multiTimerOverlayOn;

  /// No description provided for @multiTimerOverlayOff.
  ///
  /// In en, this message translates to:
  /// **'Hide overlays'**
  String get multiTimerOverlayOff;

  /// No description provided for @multiTimerOverlayPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow \"Display over other apps\" to use overlays'**
  String get multiTimerOverlayPermission;

  /// No description provided for @multiTimerOverlayLimit.
  ///
  /// In en, this message translates to:
  /// **'You can float up to {count} overlays'**
  String multiTimerOverlayLimit(int count);

  /// No description provided for @multiTimerAllDone.
  ///
  /// In en, this message translates to:
  /// **'{count} timers finished'**
  String multiTimerAllDone(int count);

  /// No description provided for @settingsOverlayMutex.
  ///
  /// In en, this message translates to:
  /// **'Show one overlay at a time'**
  String get settingsOverlayMutex;

  /// No description provided for @settingsOverlayMutexDesc.
  ///
  /// In en, this message translates to:
  /// **'Turning on the timer overlay or the multi-timer overlays turns off the other. Prevents lag from running both at once.'**
  String get settingsOverlayMutexDesc;

  /// No description provided for @multiTimerPresetStudy.
  ///
  /// In en, this message translates to:
  /// **'Study focus'**
  String get multiTimerPresetStudy;

  /// No description provided for @multiTimerPresetDeskCleanup.
  ///
  /// In en, this message translates to:
  /// **'Desk cleanup'**
  String get multiTimerPresetDeskCleanup;

  /// No description provided for @multiTimerPresetRest.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get multiTimerPresetRest;

  /// No description provided for @multiTimerPresetBrushTeeth.
  ///
  /// In en, this message translates to:
  /// **'Brush teeth'**
  String get multiTimerPresetBrushTeeth;

  /// No description provided for @multiTimerPresetSave.
  ///
  /// In en, this message translates to:
  /// **'Save as preset'**
  String get multiTimerPresetSave;

  /// No description provided for @multiTimerPresetSaved.
  ///
  /// In en, this message translates to:
  /// **'Preset saved'**
  String get multiTimerPresetSaved;

  /// No description provided for @multiTimerPresetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted'**
  String get multiTimerPresetDeleted;

  /// No description provided for @multiTimerPresetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit presets'**
  String get multiTimerPresetEdit;

  /// No description provided for @multiTimerEditDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get multiTimerEditDone;

  /// No description provided for @multiTimerStateIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get multiTimerStateIdle;

  /// No description provided for @multiTimerStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get multiTimerStatePaused;

  /// No description provided for @multiTimerPresetEditHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a preset to copy it into the fields'**
  String get multiTimerPresetEditHint;

  /// No description provided for @multiTimerPresetStarted.
  ///
  /// In en, this message translates to:
  /// **'Started \'{name}\''**
  String multiTimerPresetStarted(String name);

  /// No description provided for @settingsSounds.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSounds;

  /// No description provided for @settingsSoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Chip taps, start/pause, completion melody'**
  String get settingsSoundsDesc;

  /// No description provided for @soundSetPop.
  ///
  /// In en, this message translates to:
  /// **'Soft pop'**
  String get soundSetPop;

  /// No description provided for @soundSetWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get soundSetWood;

  /// No description provided for @soundSetGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get soundSetGlass;

  /// No description provided for @soundSetRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get soundSetRetro;

  /// No description provided for @workoutTab.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTab;

  /// No description provided for @workoutMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get workoutMyRoutines;

  /// No description provided for @workoutNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'+ New routine'**
  String get workoutNewRoutine;

  /// No description provided for @workoutRoutineN.
  ///
  /// In en, this message translates to:
  /// **'Routine {n}'**
  String workoutRoutineN(int n);

  /// No description provided for @workoutLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get workoutLibrary;

  /// No description provided for @workoutLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'tap to add · pace presets built in'**
  String get workoutLibraryHint;

  /// No description provided for @workoutEmptyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Add exercises from the library below'**
  String get workoutEmptyRoutine;

  /// No description provided for @workoutRest.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get workoutRest;

  /// No description provided for @workoutRestCommon.
  ///
  /// In en, this message translates to:
  /// **'shared across the routine'**
  String get workoutRestCommon;

  /// No description provided for @workoutVoiceTone.
  ///
  /// In en, this message translates to:
  /// **'Voice tone'**
  String get workoutVoiceTone;

  /// No description provided for @workoutToneCoach.
  ///
  /// In en, this message translates to:
  /// **'🔥 Coach'**
  String get workoutToneCoach;

  /// No description provided for @workoutToneCalm.
  ///
  /// In en, this message translates to:
  /// **'🌙 Calm'**
  String get workoutToneCalm;

  /// No description provided for @workoutSpeakSection.
  ///
  /// In en, this message translates to:
  /// **'What to announce'**
  String get workoutSpeakSection;

  /// No description provided for @workoutSpeakAllOff.
  ///
  /// In en, this message translates to:
  /// **'each can be turned off'**
  String get workoutSpeakAllOff;

  /// No description provided for @workoutSayCount.
  ///
  /// In en, this message translates to:
  /// **'Rep count'**
  String get workoutSayCount;

  /// No description provided for @workoutSayCountSub.
  ///
  /// In en, this message translates to:
  /// **'one, two, three…'**
  String get workoutSayCountSub;

  /// No description provided for @workoutSaySetAnn.
  ///
  /// In en, this message translates to:
  /// **'Set start & end'**
  String get workoutSaySetAnn;

  /// No description provided for @workoutSayCallout.
  ///
  /// In en, this message translates to:
  /// **'Time-left callouts'**
  String get workoutSayCallout;

  /// No description provided for @workoutSayCountdown.
  ///
  /// In en, this message translates to:
  /// **'Rest countdown 3·2·1'**
  String get workoutSayCountdown;

  /// No description provided for @workoutSayPreview.
  ///
  /// In en, this message translates to:
  /// **'Next exercise preview'**
  String get workoutSayPreview;

  /// No description provided for @workoutSayCheer.
  ///
  /// In en, this message translates to:
  /// **'Encouragement'**
  String get workoutSayCheer;

  /// No description provided for @workoutSayCheerSub.
  ///
  /// In en, this message translates to:
  /// **'minimal in calm tone'**
  String get workoutSayCheerSub;

  /// No description provided for @workoutDucking.
  ///
  /// In en, this message translates to:
  /// **'Music ducking'**
  String get workoutDucking;

  /// No description provided for @workoutDuckingSub.
  ///
  /// In en, this message translates to:
  /// **'lowers music volume while speaking'**
  String get workoutDuckingSub;

  /// No description provided for @workoutSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutSets;

  /// No description provided for @workoutReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workoutReps;

  /// No description provided for @workoutPace.
  ///
  /// In en, this message translates to:
  /// **'Count pace'**
  String get workoutPace;

  /// No description provided for @workoutPaceFreeSub.
  ///
  /// In en, this message translates to:
  /// **'counts forever until you tap Next'**
  String get workoutPaceFreeSub;

  /// No description provided for @workoutHoldTime.
  ///
  /// In en, this message translates to:
  /// **'Hold time'**
  String get workoutHoldTime;

  /// No description provided for @workoutStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get workoutStart;

  /// No description provided for @workoutTtsNote.
  ///
  /// In en, this message translates to:
  /// **'🔊 Spoken cues will play'**
  String get workoutTtsNote;

  /// No description provided for @workoutSetProgress.
  ///
  /// In en, this message translates to:
  /// **'Set {cur} of {total}'**
  String workoutSetProgress(int cur, int total);

  /// No description provided for @workoutRepOf.
  ///
  /// In en, this message translates to:
  /// **'of {n} reps'**
  String workoutRepOf(int n);

  /// No description provided for @workoutFreeCount.
  ///
  /// In en, this message translates to:
  /// **'Free count'**
  String get workoutFreeCount;

  /// No description provided for @workoutFreeHint.
  ///
  /// In en, this message translates to:
  /// **'tap Next to finish'**
  String get workoutFreeHint;

  /// No description provided for @workoutHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get workoutHold;

  /// No description provided for @workoutRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutRestLabel;

  /// No description provided for @workoutNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String workoutNextLabel(String name);

  /// No description provided for @workoutDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout complete!'**
  String get workoutDoneTitle;

  /// No description provided for @workoutDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{n} exercises done'**
  String workoutDoneCount(int n);

  /// No description provided for @workoutStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get workoutStop;

  /// No description provided for @workoutSkip.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get workoutSkip;

  /// No description provided for @workoutBackToStart.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get workoutBackToStart;

  /// No description provided for @exSquat.
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get exSquat;

  /// No description provided for @exPushup.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get exPushup;

  /// No description provided for @exLunge.
  ///
  /// In en, this message translates to:
  /// **'Lunges'**
  String get exLunge;

  /// No description provided for @exBurpee.
  ///
  /// In en, this message translates to:
  /// **'Burpees'**
  String get exBurpee;

  /// No description provided for @exCrunch.
  ///
  /// In en, this message translates to:
  /// **'Crunches'**
  String get exCrunch;

  /// No description provided for @exPlank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get exPlank;

  /// No description provided for @exWallsit.
  ///
  /// In en, this message translates to:
  /// **'Wall sit'**
  String get exWallsit;

  /// No description provided for @exPullup.
  ///
  /// In en, this message translates to:
  /// **'Pull-ups'**
  String get exPullup;

  /// No description provided for @wsSetStart.
  ///
  /// In en, this message translates to:
  /// **'{name}, set {set}, {reps} reps. Go!'**
  String wsSetStart(String name, int set, int reps);

  /// No description provided for @wsSetStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Set {set}. Go!'**
  String wsSetStartAgain(int set);

  /// No description provided for @wsTimeStart.
  ///
  /// In en, this message translates to:
  /// **'{name}, {dur} seconds. Go!'**
  String wsTimeStart(String name, int dur);

  /// No description provided for @wsFreeStart.
  ///
  /// In en, this message translates to:
  /// **'{name}, free count. Go!'**
  String wsFreeStart(String name);

  /// No description provided for @wsLastSet.
  ///
  /// In en, this message translates to:
  /// **'Last set! Push through'**
  String get wsLastSet;

  /// No description provided for @wsHalfway.
  ///
  /// In en, this message translates to:
  /// **'Halfway there'**
  String get wsHalfway;

  /// No description provided for @wsTenLeft.
  ///
  /// In en, this message translates to:
  /// **'Ten seconds left'**
  String get wsTenLeft;

  /// No description provided for @wsSetDoneRest.
  ///
  /// In en, this message translates to:
  /// **'Set {set} done. Rest {rest} seconds'**
  String wsSetDoneRest(int set, int rest);

  /// No description provided for @wsExDoneRest.
  ///
  /// In en, this message translates to:
  /// **'{name} done. Rest {rest} seconds'**
  String wsExDoneRest(String name, int rest);

  /// No description provided for @wsNextEx.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}, {amount}'**
  String wsNextEx(String name, String amount);

  /// No description provided for @wsNextSet.
  ///
  /// In en, this message translates to:
  /// **'Next: set {set}'**
  String wsNextSet(int set);

  /// No description provided for @wsAllDone.
  ///
  /// In en, this message translates to:
  /// **'Workout complete! Great job'**
  String get wsAllDone;

  /// No description provided for @wsAmountTime.
  ///
  /// In en, this message translates to:
  /// **'{dur} seconds'**
  String wsAmountTime(int dur);

  /// No description provided for @wsAmountReps.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps'**
  String wsAmountReps(int reps);

  /// No description provided for @wsAmountFree.
  ///
  /// In en, this message translates to:
  /// **'free count'**
  String get wsAmountFree;

  /// No description provided for @workoutSummaryReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets × {reps} reps · {pace}s'**
  String workoutSummaryReps(int sets, int reps, String pace);

  /// No description provided for @workoutSummaryTime.
  ///
  /// In en, this message translates to:
  /// **'{dur}s hold'**
  String workoutSummaryTime(int dur);

  /// No description provided for @workoutSummaryFree.
  ///
  /// In en, this message translates to:
  /// **'free count · {pace}s'**
  String workoutSummaryFree(String pace);

  /// No description provided for @workoutCustomAdd.
  ///
  /// In en, this message translates to:
  /// **'+ Custom exercise'**
  String get workoutCustomAdd;

  /// No description provided for @workoutCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Create custom exercise'**
  String get workoutCustomTitle;

  /// No description provided for @workoutCustomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Exercise name (e.g. Deadlift)'**
  String get workoutCustomNameHint;

  /// No description provided for @workoutTypeReps.
  ///
  /// In en, this message translates to:
  /// **'Sets × reps'**
  String get workoutTypeReps;

  /// No description provided for @workoutTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get workoutTypeTime;

  /// No description provided for @workoutTypeFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get workoutTypeFree;

  /// No description provided for @workoutCustomRepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Default 3 sets × 10 reps · pace 2.0s — edit in routine'**
  String get workoutCustomRepsDesc;

  /// No description provided for @workoutCustomTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Default 30s hold — edit in routine'**
  String get workoutCustomTimeDesc;

  /// No description provided for @workoutCustomFreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Endless count, manual finish · pace 2.0s'**
  String get workoutCustomFreeDesc;

  /// No description provided for @workoutCustomCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutCustomCancel;

  /// No description provided for @workoutCustomCreate.
  ///
  /// In en, this message translates to:
  /// **'Create & add'**
  String get workoutCustomCreate;

  /// No description provided for @workoutSecsLeft.
  ///
  /// In en, this message translates to:
  /// **'{t}s left'**
  String workoutSecsLeft(int t);

  /// No description provided for @wsGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready! Starting soon'**
  String get wsGetReady;

  /// No description provided for @prepTab.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get prepTab;

  /// No description provided for @prepTitle.
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get prepTitle;

  /// No description provided for @prepAutoReset.
  ///
  /// In en, this message translates to:
  /// **'resets every morning 🌅'**
  String get prepAutoReset;

  /// No description provided for @prepAutoResetHint.
  ///
  /// In en, this message translates to:
  /// **'🌙 lists are not auto-reset'**
  String get prepAutoResetHint;

  /// No description provided for @prepAllPacked.
  ///
  /// In en, this message translates to:
  /// **'All packed ✓'**
  String get prepAllPacked;

  /// No description provided for @prepPackedCount.
  ///
  /// In en, this message translates to:
  /// **'{n}/{m} packed'**
  String prepPackedCount(int n, int m);

  /// No description provided for @prepAllPackedGo.
  ///
  /// In en, this message translates to:
  /// **'All packed — go! ✓'**
  String get prepAllPackedGo;

  /// No description provided for @prepCongrats.
  ///
  /// In en, this message translates to:
  /// **'🎉 All packed!'**
  String get prepCongrats;

  /// No description provided for @prepNewListHint.
  ///
  /// In en, this message translates to:
  /// **'New list (e.g. Travel)'**
  String get prepNewListHint;

  /// No description provided for @prepEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get prepEdit;

  /// No description provided for @prepEditDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get prepEditDone;

  /// No description provided for @prepAddItemHint.
  ///
  /// In en, this message translates to:
  /// **'Add item, then Enter'**
  String get prepAddItemHint;

  /// No description provided for @prepDailyReset.
  ///
  /// In en, this message translates to:
  /// **'Reset every morning'**
  String get prepDailyReset;

  /// No description provided for @prepDailyResetHint.
  ///
  /// In en, this message translates to:
  /// **'off = manual reset (one-off lists like travel)'**
  String get prepDailyResetHint;

  /// No description provided for @prepDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get prepDeleteList;

  /// No description provided for @prepUncheckAll.
  ///
  /// In en, this message translates to:
  /// **'Uncheck all'**
  String get prepUncheckAll;

  /// No description provided for @prepEmptyItems.
  ///
  /// In en, this message translates to:
  /// **'No items — tap Edit to add'**
  String get prepEmptyItems;

  /// No description provided for @prepEmptyItemsEdit.
  ///
  /// In en, this message translates to:
  /// **'Add items below'**
  String get prepEmptyItemsEdit;

  /// No description provided for @careSection.
  ///
  /// In en, this message translates to:
  /// **'Sound & interruptions'**
  String get careSection;

  /// No description provided for @careQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get careQuietHours;

  /// No description provided for @careQuietHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'22:00–07:00 vibrate instead of sounds'**
  String get careQuietHoursDesc;

  /// No description provided for @carePreAlarm.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert'**
  String get carePreAlarm;

  /// No description provided for @carePreAlarmDesc.
  ///
  /// In en, this message translates to:
  /// **'silent heads-up before a timer ends'**
  String get carePreAlarmDesc;

  /// No description provided for @carePreAlarmOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get carePreAlarmOff;

  /// No description provided for @carePreAlarmMin.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String carePreAlarmMin(int n);

  /// No description provided for @careTone.
  ///
  /// In en, this message translates to:
  /// **'Alert wording'**
  String get careTone;

  /// No description provided for @careToneDesc.
  ///
  /// In en, this message translates to:
  /// **'tone used in completion messages'**
  String get careToneDesc;

  /// No description provided for @careToneWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get careToneWarm;

  /// No description provided for @careToneNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get careToneNeutral;

  /// No description provided for @careToneBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get careToneBrief;

  /// No description provided for @careTonePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get careTonePreview;

  /// No description provided for @doneMsgWarm.
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' is done. Nice work ☺'**
  String doneMsgWarm(String name);

  /// No description provided for @doneMsgNeutral.
  ///
  /// In en, this message translates to:
  /// **'{name} · 00:00'**
  String doneMsgNeutral(String name);

  /// No description provided for @doneMsgBrief.
  ///
  /// In en, this message translates to:
  /// **'{name} done'**
  String doneMsgBrief(String name);

  /// No description provided for @preAlarmBanner.
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' — {n} min left'**
  String preAlarmBanner(String name, int n);

  /// No description provided for @preAlarmExtend.
  ///
  /// In en, this message translates to:
  /// **'+5 min'**
  String get preAlarmExtend;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get catCooking;

  /// No description provided for @catFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get catFocus;

  /// No description provided for @catChore.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get catChore;

  /// No description provided for @presetRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get presetRecent;

  /// No description provided for @cookRamen.
  ///
  /// In en, this message translates to:
  /// **'Ramen'**
  String get cookRamen;

  /// No description provided for @cookPasta.
  ///
  /// In en, this message translates to:
  /// **'Boil pasta'**
  String get cookPasta;

  /// No description provided for @cookEgg.
  ///
  /// In en, this message translates to:
  /// **'Soft-boiled egg'**
  String get cookEgg;

  /// No description provided for @cookSauce.
  ///
  /// In en, this message translates to:
  /// **'Reduce sauce'**
  String get cookSauce;

  /// No description provided for @cookRice.
  ///
  /// In en, this message translates to:
  /// **'Soak rice'**
  String get cookRice;

  /// No description provided for @alarmDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer finished'**
  String get alarmDoneTitle;

  /// No description provided for @alarmMultiDone.
  ///
  /// In en, this message translates to:
  /// **'{n} finished'**
  String alarmMultiDone(int n);

  /// No description provided for @alarmOf.
  ///
  /// In en, this message translates to:
  /// **'{d} timer'**
  String alarmOf(String d);

  /// No description provided for @alarmAck.
  ///
  /// In en, this message translates to:
  /// **'Done ✓'**
  String get alarmAck;

  /// No description provided for @alarmAckOnly.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get alarmAckOnly;

  /// No description provided for @alarmExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended {n}×'**
  String alarmExtended(int n);

  /// No description provided for @alarmRealarmNote.
  ///
  /// In en, this message translates to:
  /// **'Rings again every minute until you confirm'**
  String get alarmRealarmNote;

  /// No description provided for @alarmRinging.
  ///
  /// In en, this message translates to:
  /// **'Done · ringing'**
  String get alarmRinging;

  /// No description provided for @alarmAgoMin.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago · rang {r}×'**
  String alarmAgoMin(int n, int r);

  /// No description provided for @alarmStillRunning.
  ///
  /// In en, this message translates to:
  /// **'Still running'**
  String get alarmStillRunning;

  /// No description provided for @alarmNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next ↓'**
  String get alarmNextUp;

  /// No description provided for @ttsOverdue.
  ///
  /// In en, this message translates to:
  /// **'{name}, {n} minutes over'**
  String ttsOverdue(String name, int n);

  /// No description provided for @careRealarm.
  ///
  /// In en, this message translates to:
  /// **'Re-ring until confirmed'**
  String get careRealarm;

  /// No description provided for @careRealarmDesc.
  ///
  /// In en, this message translates to:
  /// **'finished timers ring every minute until acknowledged'**
  String get careRealarmDesc;

  /// No description provided for @loopToggleDesc.
  ///
  /// In en, this message translates to:
  /// **'auto-repeat multiple steps'**
  String get loopToggleDesc;

  /// No description provided for @loopAddStep.
  ///
  /// In en, this message translates to:
  /// **'+ Add step (max 4)'**
  String get loopAddStep;

  /// No description provided for @loopRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get loopRepeat;

  /// No description provided for @loopTotal.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get loopTotal;

  /// No description provided for @loopSaveStart.
  ///
  /// In en, this message translates to:
  /// **'Save & start'**
  String get loopSaveStart;

  /// No description provided for @loopStepTag.
  ///
  /// In en, this message translates to:
  /// **'{step} {round}/{total}'**
  String loopStepTag(String step, int round, int total);

  /// No description provided for @loopRoundStart.
  ///
  /// In en, this message translates to:
  /// **'Round {n} — {step} started'**
  String loopRoundStart(int n, String step);

  /// No description provided for @loopStepStart.
  ///
  /// In en, this message translates to:
  /// **'{step} started'**
  String loopStepStart(String step);

  /// No description provided for @loopSkipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip step'**
  String get loopSkipStep;

  /// No description provided for @careIntervalCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking interval'**
  String get careIntervalCooking;

  /// No description provided for @careIntervalChore.
  ///
  /// In en, this message translates to:
  /// **'Chores interval'**
  String get careIntervalChore;

  /// No description provided for @careIntervalOther.
  ///
  /// In en, this message translates to:
  /// **'Other interval'**
  String get careIntervalOther;

  /// No description provided for @careTtsName.
  ///
  /// In en, this message translates to:
  /// **'Speak timer name'**
  String get careTtsName;

  /// No description provided for @careTtsNameDesc.
  ///
  /// In en, this message translates to:
  /// **'\"Boil pasta, finished\"'**
  String get careTtsNameDesc;

  /// No description provided for @careKeepDone.
  ///
  /// In en, this message translates to:
  /// **'Keep finished timers'**
  String get careKeepDone;

  /// No description provided for @careKeepDoneDesc.
  ///
  /// In en, this message translates to:
  /// **'leave completed timers in the list'**
  String get careKeepDoneDesc;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsToday;

  /// No description provided for @statsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsWeek;

  /// No description provided for @statsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsMonth;

  /// No description provided for @statsFocusedTime.
  ///
  /// In en, this message translates to:
  /// **'{period} focused time'**
  String statsFocusedTime(String period);

  /// No description provided for @statsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statsSessions;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @statsBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statsBest;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'{n}d'**
  String statsDays(int n);

  /// No description provided for @statsSessionsN.
  ///
  /// In en, this message translates to:
  /// **'{n}x'**
  String statsSessionsN(int n);

  /// No description provided for @statsLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get statsLast7;

  /// No description provided for @statsByActivity.
  ///
  /// In en, this message translates to:
  /// **'By activity'**
  String get statsByActivity;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet — finish a timer to see stats'**
  String get statsEmpty;

  /// No description provided for @statsInsightTop.
  ///
  /// In en, this message translates to:
  /// **'You focused most on {day}. Now on a {n}-day streak!'**
  String statsInsightTop(String day, int n);

  /// No description provided for @statsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data stays on this device. No account, no cloud.'**
  String get statsPrivacy;

  /// No description provided for @statsHoursMin.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String statsHoursMin(int h, int m);

  /// No description provided for @statsMinOnly.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String statsMinOnly(int m);

  /// No description provided for @settingsStats.
  ///
  /// In en, this message translates to:
  /// **'Activity statistics'**
  String get settingsStats;

  /// No description provided for @settingsStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'focused time, sessions, streak'**
  String get settingsStatsDesc;

  /// No description provided for @onboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s make sure alarms ring'**
  String get onboardTitle;

  /// No description provided for @onboardSub.
  ///
  /// In en, this message translates to:
  /// **'Just two things. Everything else works out of the box.'**
  String get onboardSub;

  /// No description provided for @onboardNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardNotifTitle;

  /// No description provided for @onboardNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'so we can tell you when a timer ends'**
  String get onboardNotifDesc;

  /// No description provided for @onboardBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep running in the background'**
  String get onboardBatteryTitle;

  /// No description provided for @onboardBatteryDesc.
  ///
  /// In en, this message translates to:
  /// **'If this stays off, alarms can silently stop after you close the app. Choose \"Unrestricted\".'**
  String get onboardBatteryDesc;

  /// No description provided for @onboardGrant.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get onboardGrant;

  /// No description provided for @onboardAllow.
  ///
  /// In en, this message translates to:
  /// **'Go allow'**
  String get onboardAllow;

  /// No description provided for @onboardDone.
  ///
  /// In en, this message translates to:
  /// **'Done ✓'**
  String get onboardDone;

  /// No description provided for @onboardLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get onboardLater;

  /// No description provided for @onboardStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardStart;

  /// No description provided for @checkAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms may stop'**
  String get checkAlarmTitle;

  /// No description provided for @checkAlarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Battery saver is putting the app to sleep. Takes a minute to fix.'**
  String get checkAlarmDesc;

  /// No description provided for @checkAlarmNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off — timers can\'t alert you.'**
  String get checkAlarmNotifDesc;

  /// No description provided for @checkFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get checkFix;

  /// No description provided for @diagTitle.
  ///
  /// In en, this message translates to:
  /// **'When alarms don\'t ring'**
  String get diagTitle;

  /// No description provided for @diagSub.
  ///
  /// In en, this message translates to:
  /// **'We checked for you. Takes a minute to fix.'**
  String get diagSub;

  /// No description provided for @diagWarnTitle.
  ///
  /// In en, this message translates to:
  /// **'{n} things need fixing'**
  String diagWarnTitle(int n);

  /// No description provided for @diagWarnDesc.
  ///
  /// In en, this message translates to:
  /// **'As is, alarms may not ring after you close the app.'**
  String get diagWarnDesc;

  /// No description provided for @diagAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything looks good'**
  String get diagAllGood;

  /// No description provided for @diagAllGoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Alarms will ring even after you close the app.'**
  String get diagAllGoodDesc;

  /// No description provided for @diagResult.
  ///
  /// In en, this message translates to:
  /// **'Check results'**
  String get diagResult;

  /// No description provided for @diagNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications allowed'**
  String get diagNotifTitle;

  /// No description provided for @diagNotifOk.
  ///
  /// In en, this message translates to:
  /// **'Alerts can show on screen'**
  String get diagNotifOk;

  /// No description provided for @diagNotifBad.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off — timers can\'t alert you.'**
  String get diagNotifBad;

  /// No description provided for @diagBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery saver exception'**
  String get diagBatteryTitle;

  /// No description provided for @diagBatteryOk.
  ///
  /// In en, this message translates to:
  /// **'The app won\'t be put to sleep'**
  String get diagBatteryOk;

  /// No description provided for @diagBatteryBad.
  ///
  /// In en, this message translates to:
  /// **'Battery saver is sleeping the app. Scheduled alarms get delayed or dropped.'**
  String get diagBatteryBad;

  /// No description provided for @diagOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display over other apps'**
  String get diagOverlayTitle;

  /// No description provided for @diagOverlayOk.
  ///
  /// In en, this message translates to:
  /// **'The overlay pill can show'**
  String get diagOverlayOk;

  /// No description provided for @diagOverlayBad.
  ///
  /// In en, this message translates to:
  /// **'The overlay pill won\'t appear.'**
  String get diagOverlayBad;

  /// No description provided for @diagFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get diagFix;

  /// No description provided for @diagFixAll.
  ///
  /// In en, this message translates to:
  /// **'Fix all'**
  String get diagFixAll;

  /// No description provided for @diagTestAlarm.
  ///
  /// In en, this message translates to:
  /// **'Send a test alarm now'**
  String get diagTestAlarm;

  /// No description provided for @diagTestNote.
  ///
  /// In en, this message translates to:
  /// **'Try closing the app after sending, to confirm it still rings.'**
  String get diagTestNote;

  /// No description provided for @diagTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test alarm sent — check your notifications'**
  String get diagTestSent;

  /// No description provided for @settingsDiag.
  ///
  /// In en, this message translates to:
  /// **'When alarms don\'t ring'**
  String get settingsDiag;

  /// No description provided for @settingsDiagDesc.
  ///
  /// In en, this message translates to:
  /// **'self-check: permissions & battery'**
  String get settingsDiagDesc;

  /// No description provided for @settingsGroupNotify.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsGroupNotify;

  /// No description provided for @settingsGroupDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsGroupDisplay;

  /// No description provided for @settingsGroupData.
  ///
  /// In en, this message translates to:
  /// **'My data'**
  String get settingsGroupData;

  /// No description provided for @settingsGroupControl.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get settingsGroupControl;

  /// No description provided for @settingsGroupHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsGroupHelp;

  /// No description provided for @settingsAlarmSection.
  ///
  /// In en, this message translates to:
  /// **'Alarms & re-ring'**
  String get settingsAlarmSection;

  /// No description provided for @settingsAlarmSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Ring again until you confirm'**
  String get settingsAlarmSectionDesc;

  /// No description provided for @settingsSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSoundSection;

  /// No description provided for @settingsSoundSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Sound effects and vibration'**
  String get settingsSoundSectionDesc;

  /// No description provided for @settingsVoiceSection.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get settingsVoiceSection;

  /// No description provided for @settingsVoiceSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Spoken alerts when you can\'t look'**
  String get settingsVoiceSectionDesc;

  /// No description provided for @alarmPageSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep reminding you until you confirm.'**
  String get alarmPageSub;

  /// No description provided for @soundPageSub.
  ///
  /// In en, this message translates to:
  /// **'Tap any option to hear it.'**
  String get soundPageSub;

  /// No description provided for @voicePageSub.
  ///
  /// In en, this message translates to:
  /// **'Speaks out loud when you can\'t look at the screen.'**
  String get voicePageSub;

  /// No description provided for @settingsSpeechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech rate'**
  String get settingsSpeechRate;

  /// No description provided for @speechRateSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speechRateSlow;

  /// No description provided for @speechRateNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speechRateNormal;

  /// No description provided for @speechRateFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speechRateFast;

  /// No description provided for @grpAlarmBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic behavior'**
  String get grpAlarmBasic;

  /// No description provided for @grpAlarmInterval.
  ///
  /// In en, this message translates to:
  /// **'Re-ring interval'**
  String get grpAlarmInterval;

  /// No description provided for @grpAlarmPrep.
  ///
  /// In en, this message translates to:
  /// **'Before it ends'**
  String get grpAlarmPrep;

  /// No description provided for @grpSoundSet.
  ///
  /// In en, this message translates to:
  /// **'Sound set'**
  String get grpSoundSet;

  /// No description provided for @grpSoundFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get grpSoundFeedback;

  /// No description provided for @grpVoiceUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get grpVoiceUse;

  /// No description provided for @grpVoiceVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get grpVoiceVoice;

  /// No description provided for @grpVoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get grpVoicePreview;

  /// No description provided for @grpVoiceWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get grpVoiceWorkout;

  /// No description provided for @grpAlarmDone.
  ///
  /// In en, this message translates to:
  /// **'Completion message'**
  String get grpAlarmDone;

  /// No description provided for @settingsListSection.
  ///
  /// In en, this message translates to:
  /// **'List display'**
  String get settingsListSection;

  /// No description provided for @settingsListSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'How timers look on the main screen'**
  String get settingsListSectionDesc;

  /// No description provided for @listPageSub.
  ///
  /// In en, this message translates to:
  /// **'Set how timers look on the main screen.'**
  String get listPageSub;

  /// No description provided for @grpListRing.
  ///
  /// In en, this message translates to:
  /// **'Progress ring'**
  String get grpListRing;

  /// No description provided for @listShowRing.
  ///
  /// In en, this message translates to:
  /// **'Show progress ring'**
  String get listShowRing;

  /// No description provided for @listShowRingDesc.
  ///
  /// In en, this message translates to:
  /// **'A filling ring shows time left at a glance'**
  String get listShowRingDesc;

  /// No description provided for @grpListSize.
  ///
  /// In en, this message translates to:
  /// **'Card size'**
  String get grpListSize;

  /// No description provided for @listDensityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get listDensityCompact;

  /// No description provided for @listDensityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get listDensityNormal;

  /// No description provided for @listDensityLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get listDensityLarge;

  /// No description provided for @grpListSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get grpListSort;

  /// No description provided for @listSortRemain.
  ///
  /// In en, this message translates to:
  /// **'Least time left'**
  String get listSortRemain;

  /// No description provided for @listSortCreated.
  ///
  /// In en, this message translates to:
  /// **'Order added'**
  String get listSortCreated;

  /// No description provided for @grpListDone.
  ///
  /// In en, this message translates to:
  /// **'Finished timers'**
  String get grpListDone;

  /// No description provided for @listKeepDone.
  ///
  /// In en, this message translates to:
  /// **'Keep in list for'**
  String get listKeepDone;

  /// No description provided for @listKeepOff.
  ///
  /// In en, this message translates to:
  /// **'Hide right away'**
  String get listKeepOff;

  /// No description provided for @listDimDone.
  ///
  /// In en, this message translates to:
  /// **'Dim finished'**
  String get listDimDone;

  /// No description provided for @listDimDoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Lower opacity for completed timers'**
  String get listDimDoneDesc;

  /// No description provided for @settingsOverlaySection.
  ///
  /// In en, this message translates to:
  /// **'Overlay pill'**
  String get settingsOverlaySection;

  /// No description provided for @settingsOverlaySectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Floating timer over other apps'**
  String get settingsOverlaySectionDesc;

  /// No description provided for @overlayPageSub.
  ///
  /// In en, this message translates to:
  /// **'See time left while using other apps.'**
  String get overlayPageSub;

  /// No description provided for @grpOverlayUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get grpOverlayUse;

  /// No description provided for @overlayShowOver.
  ///
  /// In en, this message translates to:
  /// **'Show over other apps'**
  String get overlayShowOver;

  /// No description provided for @overlayShowOverDesc.
  ///
  /// In en, this message translates to:
  /// **'Needs the display-over-apps permission'**
  String get overlayShowOverDesc;

  /// No description provided for @overlayShowLock.
  ///
  /// In en, this message translates to:
  /// **'Show on lock screen'**
  String get overlayShowLock;

  /// No description provided for @overlayShowLockDesc.
  ///
  /// In en, this message translates to:
  /// **'May be limited by your device'**
  String get overlayShowLockDesc;

  /// No description provided for @grpOverlaySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get grpOverlaySize;

  /// No description provided for @overlaySizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get overlaySizeSmall;

  /// No description provided for @overlaySizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get overlaySizeNormal;

  /// No description provided for @overlaySizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get overlaySizeLarge;

  /// No description provided for @grpOverlaySide.
  ///
  /// In en, this message translates to:
  /// **'Edge'**
  String get grpOverlaySide;

  /// No description provided for @overlaySideLeft.
  ///
  /// In en, this message translates to:
  /// **'Left edge'**
  String get overlaySideLeft;

  /// No description provided for @overlaySideRight.
  ///
  /// In en, this message translates to:
  /// **'Right edge'**
  String get overlaySideRight;

  /// No description provided for @grpOverlayContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get grpOverlayContent;

  /// No description provided for @overlayShowName.
  ///
  /// In en, this message translates to:
  /// **'Timer name'**
  String get overlayShowName;

  /// No description provided for @overlayShowNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Off shows time only'**
  String get overlayShowNameDesc;

  /// No description provided for @overlayAutoHide.
  ///
  /// In en, this message translates to:
  /// **'Auto-hide when finished'**
  String get overlayAutoHide;

  /// No description provided for @overlayAutoHideDesc.
  ///
  /// In en, this message translates to:
  /// **'Disappears once acknowledged'**
  String get overlayAutoHideDesc;

  /// No description provided for @overlayGrantCta.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get overlayGrantCta;

  /// No description provided for @overlayPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to move it'**
  String get overlayPreviewHint;

  /// No description provided for @overlayPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get overlayPreviewLabel;

  /// No description provided for @textTimerEntry.
  ///
  /// In en, this message translates to:
  /// **'Say or type'**
  String get textTimerEntry;

  /// No description provided for @textTimerEntryDesc.
  ///
  /// In en, this message translates to:
  /// **'“Ramen 4 and a half min, egg 6 min”'**
  String get textTimerEntryDesc;

  /// No description provided for @textTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Say or type'**
  String get textTimerTitle;

  /// No description provided for @textTimerInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 라면 사분반, 계란 육분'**
  String get textTimerInputHint;

  /// No description provided for @textTimerHelper.
  ///
  /// In en, this message translates to:
  /// **'Write several at once, separated by commas.'**
  String get textTimerHelper;

  /// No description provided for @textTimerExamplesHead.
  ///
  /// In en, this message translates to:
  /// **'Try writing like this'**
  String get textTimerExamplesHead;

  /// No description provided for @textTimerOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline · nothing is uploaded'**
  String get textTimerOffline;

  /// No description provided for @textTimerParse.
  ///
  /// In en, this message translates to:
  /// **'Read it'**
  String get textTimerParse;

  /// No description provided for @textTimerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Make these?'**
  String get textTimerConfirmTitle;

  /// No description provided for @textTimerConfirmSub.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to remove it, or rewrite.'**
  String get textTimerConfirmSub;

  /// No description provided for @textTimerRetype.
  ///
  /// In en, this message translates to:
  /// **'Rewrite'**
  String get textTimerRetype;

  /// No description provided for @textTimerStartN.
  ///
  /// In en, this message translates to:
  /// **'Start {n}'**
  String textTimerStartN(int n);

  /// No description provided for @textTimerSaveN.
  ///
  /// In en, this message translates to:
  /// **'Save as presets'**
  String get textTimerSaveN;

  /// No description provided for @textTimerUnparsed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find a time · rewrite this part'**
  String get textTimerUnparsed;

  /// No description provided for @textTimerFromPreset.
  ///
  /// In en, this message translates to:
  /// **'Existing preset · kept its color & alarm'**
  String get textTimerFromPreset;

  /// No description provided for @textTimerRangeShort.
  ///
  /// In en, this message translates to:
  /// **'Picked the shorter side'**
  String get textTimerRangeShort;

  /// No description provided for @textTimerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to start yet'**
  String get textTimerEmpty;

  /// No description provided for @textTimerNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time found. Try “ramen 4 min”.'**
  String get textTimerNoTime;

  /// No description provided for @settingsVoiceStart.
  ///
  /// In en, this message translates to:
  /// **'Start by voice'**
  String get settingsVoiceStart;

  /// No description provided for @settingsVoiceStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn on timers by talking, hands-free'**
  String get settingsVoiceStartDesc;

  /// No description provided for @voiceStartSub.
  ///
  /// In en, this message translates to:
  /// **'Turn on a timer by talking — no need to pick up your phone.'**
  String get voiceStartSub;

  /// No description provided for @voiceHeroHint.
  ///
  /// In en, this message translates to:
  /// **'Say this and a 25-min focus starts right away'**
  String get voiceHeroHint;

  /// No description provided for @voiceHeroQuote.
  ///
  /// In en, this message translates to:
  /// **'“Hey Google, start focus”'**
  String get voiceHeroQuote;

  /// No description provided for @voiceRoutineHead.
  ///
  /// In en, this message translates to:
  /// **'Turn on automatically'**
  String get voiceRoutineHead;

  /// No description provided for @voiceRoutineSub.
  ///
  /// In en, this message translates to:
  /// **'Add to a Galaxy routine and it starts without you saying anything.'**
  String get voiceRoutineSub;

  /// No description provided for @voiceRecipeHead.
  ///
  /// In en, this message translates to:
  /// **'Suggested recipes'**
  String get voiceRecipeHead;

  /// No description provided for @recipeDesk.
  ///
  /// In en, this message translates to:
  /// **'Focus when I sit at my desk'**
  String get recipeDesk;

  /// No description provided for @recipeDeskWhen.
  ///
  /// In en, this message translates to:
  /// **'Home Wi-Fi + weekday afternoon'**
  String get recipeDeskWhen;

  /// No description provided for @recipeCharge.
  ///
  /// In en, this message translates to:
  /// **'Focus when I put it on the charger'**
  String get recipeCharge;

  /// No description provided for @recipeChargeWhen.
  ///
  /// In en, this message translates to:
  /// **'Charging starts · with Do Not Disturb'**
  String get recipeChargeWhen;

  /// No description provided for @recipeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Voice mode when I open a workout app'**
  String get recipeWorkout;

  /// No description provided for @recipeWorkoutWhen.
  ///
  /// In en, this message translates to:
  /// **'A specific app launches'**
  String get recipeWorkoutWhen;

  /// No description provided for @recipeSleep.
  ///
  /// In en, this message translates to:
  /// **'Stop everything at bedtime'**
  String get recipeSleep;

  /// No description provided for @recipeSleepWhen.
  ///
  /// In en, this message translates to:
  /// **'Bedtime mode begins'**
  String get recipeSleepWhen;

  /// No description provided for @routineCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied the \'{name}\' link'**
  String routineCopied(String name);

  /// No description provided for @routineStepsHead.
  ///
  /// In en, this message translates to:
  /// **'Now do this'**
  String get routineStepsHead;

  /// No description provided for @routineStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the Routines app'**
  String get routineStep1;

  /// No description provided for @routineStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'The button below opens it'**
  String get routineStep1Desc;

  /// No description provided for @routineStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick ‘Open app’ as the action'**
  String get routineStep2;

  /// No description provided for @routineStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Long-press the address field and paste'**
  String get routineStep2Desc;

  /// No description provided for @routineStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose a condition and save'**
  String get routineStep3;

  /// No description provided for @routineStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi · time · place — anything'**
  String get routineStep3Desc;

  /// No description provided for @routineOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Routines app'**
  String get routineOpenApp;

  /// No description provided for @routineCantOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the Routines app. The link is copied — paste it there.'**
  String get routineCantOpen;

  /// No description provided for @voiceStarted.
  ///
  /// In en, this message translates to:
  /// **'Started by voice'**
  String get voiceStarted;

  /// No description provided for @voiceStartedTimer.
  ///
  /// In en, this message translates to:
  /// **'Started ‘{name}’'**
  String voiceStartedTimer(String name);

  /// No description provided for @voiceStopHint.
  ///
  /// In en, this message translates to:
  /// **'Several timers are running — open the app to choose.'**
  String get voiceStopHint;

  /// No description provided for @scFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus 25 min'**
  String get scFocus;

  /// No description provided for @scRest.
  ///
  /// In en, this message translates to:
  /// **'Break 5 min'**
  String get scRest;

  /// No description provided for @scStop.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get scStop;

  /// No description provided for @scStatus.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get scStatus;

  /// No description provided for @ocrEntry.
  ///
  /// In en, this message translates to:
  /// **'Scan a package'**
  String get ocrEntry;

  /// No description provided for @ocrEntryDesc.
  ///
  /// In en, this message translates to:
  /// **'Reads the cook time and makes it'**
  String get ocrEntryDesc;

  /// No description provided for @ocrCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get ocrCamera;

  /// No description provided for @ocrAlbum.
  ///
  /// In en, this message translates to:
  /// **'Pick from album'**
  String get ocrAlbum;

  /// No description provided for @ocrReading.
  ///
  /// In en, this message translates to:
  /// **'Reading text…'**
  String get ocrReading;

  /// No description provided for @ocrNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time found — set it by hand'**
  String get ocrNoTime;

  /// No description provided for @ocrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan package'**
  String get ocrTitle;

  /// No description provided for @seqParallel.
  ///
  /// In en, this message translates to:
  /// **'Start together'**
  String get seqParallel;

  /// No description provided for @seqSequential.
  ///
  /// In en, this message translates to:
  /// **'One after another'**
  String get seqSequential;

  /// No description provided for @seqNote.
  ///
  /// In en, this message translates to:
  /// **'Each step starts when the previous finishes.'**
  String get seqNote;

  /// No description provided for @seqAckTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm before next'**
  String get seqAckTitle;

  /// No description provided for @seqAckAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-picked'**
  String get seqAckAuto;

  /// No description provided for @seqAckOnNote.
  ///
  /// In en, this message translates to:
  /// **'Next starts when you confirm each step — for hands-on recipes.'**
  String get seqAckOnNote;

  /// No description provided for @seqAckOffNote.
  ///
  /// In en, this message translates to:
  /// **'Next starts right after each step — for continuous steps.'**
  String get seqAckOffNote;

  /// No description provided for @seqFinishTogether.
  ///
  /// In en, this message translates to:
  /// **'Finish together'**
  String get seqFinishTogether;

  /// No description provided for @seqFinishNote.
  ///
  /// In en, this message translates to:
  /// **'Starts with the longest first so everything finishes at the same time.'**
  String get seqFinishNote;

  /// No description provided for @seqFinishAt.
  ///
  /// In en, this message translates to:
  /// **'All done at {time}'**
  String seqFinishAt(String time);

  /// No description provided for @ftWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get ftWaiting;

  /// No description provided for @ftStartArmed.
  ///
  /// In en, this message translates to:
  /// **'Time to start'**
  String get ftStartArmed;

  /// No description provided for @ftStartIn.
  ///
  /// In en, this message translates to:
  /// **'starts in {t}'**
  String ftStartIn(String t);

  /// No description provided for @ftStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get ftStartNow;

  /// No description provided for @ftDriftTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} will finish {min} min late'**
  String ftDriftTitle(String name, int min);

  /// No description provided for @ftDriftDesc.
  ///
  /// In en, this message translates to:
  /// **'Extend the running one to realign, or leave it.'**
  String get ftDriftDesc;

  /// No description provided for @ftDriftExtend.
  ///
  /// In en, this message translates to:
  /// **'{name} +{min}:00'**
  String ftDriftExtend(String name, int min);

  /// No description provided for @ftDriftLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave it'**
  String get ftDriftLeave;

  /// No description provided for @ftStartArmedMsg.
  ///
  /// In en, this message translates to:
  /// **'Time to start {name} — confirm to start'**
  String ftStartArmedMsg(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @presetDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String presetDeletedToast(String name);

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water reminder'**
  String get waterTitle;

  /// No description provided for @waterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get waterToday;

  /// No description provided for @waterCups.
  ///
  /// In en, this message translates to:
  /// **'{n} / {goal} cups'**
  String waterCups(int n, int goal);

  /// No description provided for @waterWhenGroup.
  ///
  /// In en, this message translates to:
  /// **'When to remind'**
  String get waterWhenGroup;

  /// No description provided for @waterInterval.
  ///
  /// In en, this message translates to:
  /// **'Every interval'**
  String get waterInterval;

  /// No description provided for @waterFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed times'**
  String get waterFixed;

  /// No description provided for @waterActiveHours.
  ///
  /// In en, this message translates to:
  /// **'Active hours only'**
  String get waterActiveHours;

  /// No description provided for @waterWithTimer.
  ///
  /// In en, this message translates to:
  /// **'With timer end'**
  String get waterWithTimer;

  /// No description provided for @waterWithTimerSub.
  ///
  /// In en, this message translates to:
  /// **'Add a water nudge when you check another alarm'**
  String get waterWithTimerSub;

  /// No description provided for @waterHowGroup.
  ///
  /// In en, this message translates to:
  /// **'How it alerts'**
  String get waterHowGroup;

  /// No description provided for @waterIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get waterIntensity;

  /// No description provided for @waterIntensitySub.
  ///
  /// In en, this message translates to:
  /// **'Rings once and steps back — no re-alarm'**
  String get waterIntensitySub;

  /// No description provided for @waterBannerMode.
  ///
  /// In en, this message translates to:
  /// **'Banner'**
  String get waterBannerMode;

  /// No description provided for @waterOneSound.
  ///
  /// In en, this message translates to:
  /// **'One sound'**
  String get waterOneSound;

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get waterGoal;

  /// No description provided for @waterGoalCups.
  ///
  /// In en, this message translates to:
  /// **'{n} cups'**
  String waterGoalCups(int n);

  /// No description provided for @waterEnable.
  ///
  /// In en, this message translates to:
  /// **'Use water reminder'**
  String get waterEnable;

  /// No description provided for @waterNote.
  ///
  /// In en, this message translates to:
  /// **'Interval counts from when you tap \"Drank\". Merges with a fixed time if within 30 min.'**
  String get waterNote;

  /// No description provided for @waterBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'A glass of water'**
  String get waterBannerTitle;

  /// No description provided for @waterBannerSub.
  ///
  /// In en, this message translates to:
  /// **'{n} today · next {time}'**
  String waterBannerSub(int n, String time);

  /// No description provided for @waterDrank.
  ///
  /// In en, this message translates to:
  /// **'Drank'**
  String get waterDrank;

  /// No description provided for @waterLater30.
  ///
  /// In en, this message translates to:
  /// **'In 30 min'**
  String get waterLater30;

  /// No description provided for @waterStopToday.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get waterStopToday;

  /// No description provided for @waterBgNote.
  ///
  /// In en, this message translates to:
  /// **'Fires even when the app is closed (needs exact-alarm permission).'**
  String get waterBgNote;

  /// No description provided for @waterSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind to drink at intervals or set times'**
  String get waterSettingsDesc;

  /// No description provided for @waterNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Time to drink water'**
  String get waterNotifBody;
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
