import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Airstyle'**
  String get appTitle;

  /// No description provided for @myDevicesTab.
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get myDevicesTab;

  /// No description provided for @userInfoTab.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfoTab;

  /// No description provided for @devicesHeadline.
  ///
  /// In en, this message translates to:
  /// **'Curling wand, refined into one connected ritual.'**
  String get devicesHeadline;

  /// No description provided for @devicesSubhead.
  ///
  /// In en, this message translates to:
  /// **'Discover, connect, and revisit your device in a focused monochrome control surface.'**
  String get devicesSubhead;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @searchNearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Search Nearby Devices'**
  String get searchNearbyDevices;

  /// No description provided for @scanToAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan to Add Device'**
  String get scanToAddDevice;

  /// No description provided for @productSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Product Serial Number'**
  String get productSerialNumber;

  /// No description provided for @featureAvailableSoon.
  ///
  /// In en, this message translates to:
  /// **'This option is coming soon.'**
  String get featureAvailableSoon;

  /// No description provided for @savedSerialNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved serial number'**
  String get savedSerialNumberLabel;

  /// No description provided for @noSavedSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'No product serial number saved yet.'**
  String get noSavedSerialNumber;

  /// No description provided for @manualSerialHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the serial number printed on the product body. It will be saved for future pairing and support.'**
  String get manualSerialHint;

  /// No description provided for @serialNumberInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter product serial number'**
  String get serialNumberInputHint;

  /// No description provided for @serialNumberHelper.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, and hyphens are supported.'**
  String get serialNumberHelper;

  /// No description provided for @serialNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid product serial number.'**
  String get serialNumberRequired;

  /// No description provided for @saveSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Save Serial Number'**
  String get saveSerialNumber;

  /// No description provided for @serialNumberSaved.
  ///
  /// In en, this message translates to:
  /// **'Serial number saved.'**
  String get serialNumberSaved;

  /// No description provided for @scanSerialHint.
  ///
  /// In en, this message translates to:
  /// **'Open the camera and capture the serial number area. The app will recognize and fill the result for you.'**
  String get scanSerialHint;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @recognizedSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Recognized result'**
  String get recognizedSerialNumber;

  /// No description provided for @recognizedText.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get recognizedText;

  /// No description provided for @editSerialBeforeSave.
  ///
  /// In en, this message translates to:
  /// **'You can edit the recognized result before saving.'**
  String get editSerialBeforeSave;

  /// No description provided for @serialNotDetected.
  ///
  /// In en, this message translates to:
  /// **'No valid serial number was detected. Try another angle or enter it manually.'**
  String get serialNotDetected;

  /// No description provided for @scanUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Camera-based serial recognition is not supported in this preview environment. Use this feature on a phone.'**
  String get scanUnsupportedBody;

  /// No description provided for @serialRecognitionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to recognize the serial number right now.'**
  String get serialRecognitionError;

  /// No description provided for @primaryDevice.
  ///
  /// In en, this message translates to:
  /// **'Primary Device'**
  String get primaryDevice;

  /// No description provided for @noDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'No device connected'**
  String get noDeviceTitle;

  /// No description provided for @noDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'Start by scanning for a nearby curling wand.'**
  String get noDeviceBody;

  /// No description provided for @scanPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Curling Wand'**
  String get scanPageTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Scanning for Bluetooth devices around you.'**
  String get scanHint;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @bluetoothOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is unavailable'**
  String get bluetoothOffTitle;

  /// No description provided for @bluetoothOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth to discover nearby devices.'**
  String get bluetoothOffBody;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission required'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow Bluetooth access to discover and connect to your curling wand.'**
  String get permissionBody;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get openSystemSettings;

  /// No description provided for @emptyScanTitle.
  ///
  /// In en, this message translates to:
  /// **'No nearby devices found'**
  String get emptyScanTitle;

  /// No description provided for @emptyScanBody.
  ///
  /// In en, this message translates to:
  /// **'Move the curling wand closer and try scanning again.'**
  String get emptyScanBody;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connectFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @deviceSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get deviceSignal;

  /// No description provided for @savedDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved device'**
  String get savedDeviceLabel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get profileTitle;

  /// No description provided for @profileSubhead.
  ///
  /// In en, this message translates to:
  /// **'Privacy, legal copy, and essential system preferences only.'**
  String get profileSubhead;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @softwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Software Version'**
  String get softwareVersion;

  /// No description provided for @languagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePageTitle;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @legalDocumentFooter.
  ///
  /// In en, this message translates to:
  /// **'Please read carefully and confirm that you understand this document.'**
  String get legalDocumentFooter;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get statusUnauthorized;

  /// No description provided for @statusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth unavailable'**
  String get statusUnavailable;

  /// No description provided for @statusScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning nearby devices'**
  String get statusScanning;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected and ready'**
  String get statusConnected;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Saved for reconnect'**
  String get statusDisconnected;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @hairProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Hair Profile'**
  String get hairProfileTitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @hairTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which hair type best matches you?'**
  String get hairTypeQuestion;

  /// No description provided for @hairTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'If your hair feels mixed, choose the type that feels most dominant.'**
  String get hairTypeDescription;

  /// No description provided for @hairTypeStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get hairTypeStraight;

  /// No description provided for @hairTypeWavy.
  ///
  /// In en, this message translates to:
  /// **'Wavy'**
  String get hairTypeWavy;

  /// No description provided for @hairTypeCurly.
  ///
  /// In en, this message translates to:
  /// **'Curly'**
  String get hairTypeCurly;

  /// No description provided for @hairTypeCoily.
  ///
  /// In en, this message translates to:
  /// **'Coily'**
  String get hairTypeCoily;

  /// No description provided for @hairLengthQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long is your hair?'**
  String get hairLengthQuestion;

  /// No description provided for @hairLengthDescription.
  ///
  /// In en, this message translates to:
  /// **'Look at your hair and estimate its overall length.'**
  String get hairLengthDescription;

  /// No description provided for @hairLengthVeryShort.
  ///
  /// In en, this message translates to:
  /// **'Very Short'**
  String get hairLengthVeryShort;

  /// No description provided for @hairLengthVeryShortHint.
  ///
  /// In en, this message translates to:
  /// **'Buzz cut to ear length'**
  String get hairLengthVeryShortHint;

  /// No description provided for @hairLengthShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get hairLengthShort;

  /// No description provided for @hairLengthShortHint.
  ///
  /// In en, this message translates to:
  /// **'Past the ear to chin length'**
  String get hairLengthShortHint;

  /// No description provided for @hairLengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hairLengthMedium;

  /// No description provided for @hairLengthMediumHint.
  ///
  /// In en, this message translates to:
  /// **'Past the chin to shoulder length'**
  String get hairLengthMediumHint;

  /// No description provided for @hairLengthLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get hairLengthLong;

  /// No description provided for @hairLengthLongHint.
  ///
  /// In en, this message translates to:
  /// **'Past the shoulder to underarm length'**
  String get hairLengthLongHint;

  /// No description provided for @hairLengthVeryLong.
  ///
  /// In en, this message translates to:
  /// **'Very Long'**
  String get hairLengthVeryLong;

  /// No description provided for @hairLengthVeryLongHint.
  ///
  /// In en, this message translates to:
  /// **'Below the underarm'**
  String get hairLengthVeryLongHint;

  /// No description provided for @hairThicknessQuestion.
  ///
  /// In en, this message translates to:
  /// **'How fine is your hair?'**
  String get hairThicknessQuestion;

  /// No description provided for @hairThicknessDescription.
  ///
  /// In en, this message translates to:
  /// **'Look closely and feel the strand thickness with your fingertips.'**
  String get hairThicknessDescription;

  /// No description provided for @hairThicknessFine.
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get hairThicknessFine;

  /// No description provided for @hairThicknessFineHint.
  ///
  /// In en, this message translates to:
  /// **'Hard to see or feel'**
  String get hairThicknessFineHint;

  /// No description provided for @hairThicknessMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hairThicknessMedium;

  /// No description provided for @hairThicknessMediumHint.
  ///
  /// In en, this message translates to:
  /// **'Visible and not difficult to feel'**
  String get hairThicknessMediumHint;

  /// No description provided for @hairThicknessCoarse.
  ///
  /// In en, this message translates to:
  /// **'Coarse'**
  String get hairThicknessCoarse;

  /// No description provided for @hairThicknessCoarseHint.
  ///
  /// In en, this message translates to:
  /// **'Very easy to see and feel'**
  String get hairThicknessCoarseHint;

  /// No description provided for @unsureOption.
  ///
  /// In en, this message translates to:
  /// **'Unsure'**
  String get unsureOption;

  /// No description provided for @styleRetentionQuestion.
  ///
  /// In en, this message translates to:
  /// **'How well does your hair hold a style?'**
  String get styleRetentionQuestion;

  /// No description provided for @styleRetentionDescription.
  ///
  /// In en, this message translates to:
  /// **'After styling, notice how long it takes to relax back.'**
  String get styleRetentionDescription;

  /// No description provided for @styleRetentionShort.
  ///
  /// In en, this message translates to:
  /// **'Not for long'**
  String get styleRetentionShort;

  /// No description provided for @styleRetentionShortHint.
  ///
  /// In en, this message translates to:
  /// **'The style lasts a little over an hour'**
  String get styleRetentionShortHint;

  /// No description provided for @styleRetentionMedium.
  ///
  /// In en, this message translates to:
  /// **'For a while'**
  String get styleRetentionMedium;

  /// No description provided for @styleRetentionMediumHint.
  ///
  /// In en, this message translates to:
  /// **'The style can last up to half a day'**
  String get styleRetentionMediumHint;

  /// No description provided for @styleRetentionLong.
  ///
  /// In en, this message translates to:
  /// **'For quite a long time'**
  String get styleRetentionLong;

  /// No description provided for @styleRetentionLongHint.
  ///
  /// In en, this message translates to:
  /// **'The style lasts a full day or longer'**
  String get styleRetentionLongHint;

  /// No description provided for @stylingExperienceQuestion.
  ///
  /// In en, this message translates to:
  /// **'How experienced are you with hair styling?'**
  String get stylingExperienceQuestion;

  /// No description provided for @stylingExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the level that best matches your styling confidence.'**
  String get stylingExperienceDescription;

  /// No description provided for @stylingExperienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get stylingExperienceBeginner;

  /// No description provided for @stylingExperienceBeginnerHint.
  ///
  /// In en, this message translates to:
  /// **'I can do simple styles, but learning new techniques can take effort.'**
  String get stylingExperienceBeginnerHint;

  /// No description provided for @stylingExperienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Some experience'**
  String get stylingExperienceIntermediate;

  /// No description provided for @stylingExperienceIntermediateHint.
  ///
  /// In en, this message translates to:
  /// **'I can create a few styles confidently and like trying new techniques.'**
  String get stylingExperienceIntermediateHint;

  /// No description provided for @stylingExperienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get stylingExperienceAdvanced;

  /// No description provided for @stylingExperienceAdvancedHint.
  ///
  /// In en, this message translates to:
  /// **'I can create complex styles easily and learn new techniques quickly.'**
  String get stylingExperienceAdvancedHint;

  /// No description provided for @stylingGoalsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are your styling goals?'**
  String get stylingGoalsQuestion;

  /// No description provided for @stylingGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'We will use these goals to personalize your styling guidance.'**
  String get stylingGoalsDescription;

  /// No description provided for @stylingGoalVolumeCurls.
  ///
  /// In en, this message translates to:
  /// **'Voluminous curls'**
  String get stylingGoalVolumeCurls;

  /// No description provided for @stylingGoalStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight hair'**
  String get stylingGoalStraight;

  /// No description provided for @stylingGoalSleek.
  ///
  /// In en, this message translates to:
  /// **'Sleek finish'**
  String get stylingGoalSleek;

  /// No description provided for @stylingGoalFrizzControl.
  ///
  /// In en, this message translates to:
  /// **'Control frizz'**
  String get stylingGoalFrizzControl;

  /// No description provided for @stylingGoalFlyawayManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage flyaways'**
  String get stylingGoalFlyawayManagement;

  /// No description provided for @stylingGoalNaturalFinish.
  ///
  /// In en, this message translates to:
  /// **'Enhance natural texture'**
  String get stylingGoalNaturalFinish;

  /// No description provided for @stylingGoalQuickStyle.
  ///
  /// In en, this message translates to:
  /// **'Fast everyday styling'**
  String get stylingGoalQuickStyle;

  /// No description provided for @stylingGoalLongLasting.
  ///
  /// In en, this message translates to:
  /// **'Long-lasting hold'**
  String get stylingGoalLongLasting;

  /// No description provided for @stylingGoalHairHealth.
  ///
  /// In en, this message translates to:
  /// **'Protect hair health'**
  String get stylingGoalHairHealth;

  /// No description provided for @deviceOverviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get deviceOverviewTab;

  /// No description provided for @deviceSupportTab.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get deviceSupportTab;

  /// No description provided for @deviceSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get deviceSettingsTab;

  /// No description provided for @deviceAbnormalStatus.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get deviceAbnormalStatus;

  /// No description provided for @deviceNoAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'No attachment detected'**
  String get deviceNoAttachmentTitle;

  /// No description provided for @deviceNoAttachmentBody.
  ///
  /// In en, this message translates to:
  /// **'Install an attachment to begin styling.'**
  String get deviceNoAttachmentBody;

  /// No description provided for @deviceAttachmentDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment detected'**
  String get deviceAttachmentDetectedTitle;

  /// No description provided for @deviceAttachmentDetectedBody.
  ///
  /// In en, this message translates to:
  /// **'View the attachment guide.'**
  String get deviceAttachmentDetectedBody;

  /// No description provided for @deviceAttachmentRequiresBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Connect the Bluetooth device first.'**
  String get deviceAttachmentRequiresBluetooth;

  /// No description provided for @deviceAutoCurlTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto curl'**
  String get deviceAutoCurlTitle;

  /// No description provided for @deviceReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get deviceReadyTitle;

  /// No description provided for @deviceReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Slide the power button upward, then release.'**
  String get deviceReadyBody;

  /// No description provided for @deviceAdjustTime.
  ///
  /// In en, this message translates to:
  /// **'Adjust Time'**
  String get deviceAdjustTime;

  /// No description provided for @deviceStatusSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get deviceStatusSectionTitle;

  /// No description provided for @deviceWindLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get deviceWindLow;

  /// No description provided for @deviceWindSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Airflow'**
  String get deviceWindSpeedLabel;

  /// No description provided for @deviceCoolAir.
  ///
  /// In en, this message translates to:
  /// **'Cool Shot'**
  String get deviceCoolAir;

  /// No description provided for @deviceTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get deviceTemperatureLabel;

  /// No description provided for @deviceTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Beginner Tutorials'**
  String get deviceTutorialTitle;

  /// No description provided for @deviceSupportGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get deviceSupportGuideTitle;

  /// No description provided for @deviceSupportGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Review features, styling steps, and common questions.'**
  String get deviceSupportGuideBody;

  /// No description provided for @deviceSupportCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Care & Maintenance'**
  String get deviceSupportCareTitle;

  /// No description provided for @deviceSupportCareBody.
  ///
  /// In en, this message translates to:
  /// **'Learn how to clean, store, and care for the device.'**
  String get deviceSupportCareBody;

  /// No description provided for @deviceBluetoothStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connection'**
  String get deviceBluetoothStatusTitle;

  /// No description provided for @deviceCurlTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Curl'**
  String get deviceCurlTimeLabel;

  /// No description provided for @deviceStyleTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get deviceStyleTimeLabel;

  /// No description provided for @deviceCoolShotTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cool Shot'**
  String get deviceCoolShotTimeLabel;

  /// No description provided for @deviceResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get deviceResetButton;

  /// No description provided for @deviceTimingSaved.
  ///
  /// In en, this message translates to:
  /// **'Timing settings saved.'**
  String get deviceTimingSaved;

  /// No description provided for @deviceGuidePageTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get deviceGuidePageTitle;

  /// No description provided for @attachmentPreStylingDryer.
  ///
  /// In en, this message translates to:
  /// **'Pre-styling dryer 2x'**
  String get attachmentPreStylingDryer;

  /// No description provided for @attachmentRoundVolumisingBrush.
  ///
  /// In en, this message translates to:
  /// **'Round volumising brush 2x'**
  String get attachmentRoundVolumisingBrush;

  /// No description provided for @attachmentAirSmooth.
  ///
  /// In en, this message translates to:
  /// **'AirSmooth 2x attachment'**
  String get attachmentAirSmooth;

  /// No description provided for @attachmentAntiTangleLoopBrush.
  ///
  /// In en, this message translates to:
  /// **'Anti-tangle loop brush 2x'**
  String get attachmentAntiTangleLoopBrush;

  /// No description provided for @attachmentCoanda30.
  ///
  /// In en, this message translates to:
  /// **'30mm Co-anda 2x barrel'**
  String get attachmentCoanda30;

  /// No description provided for @attachmentCoanda40.
  ///
  /// In en, this message translates to:
  /// **'40mm Co-anda 2x barrel'**
  String get attachmentCoanda40;

  /// No description provided for @deleteDeviceDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Device Data'**
  String get deleteDeviceDataTitle;

  /// No description provided for @deleteDeviceDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the saved connection record and local settings for this device.'**
  String get deleteDeviceDataMessage;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deviceDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Device data deleted.'**
  String get deviceDataDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
