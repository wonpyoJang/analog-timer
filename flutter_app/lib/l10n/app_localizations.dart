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
  /// **'Include Ctrl, Alt or Win (Shift alone would hijack normal typing)'**
  String get hotkeyNeedModifier;

  /// No description provided for @hotkeyDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already used by another action'**
  String get hotkeyDuplicate;

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
