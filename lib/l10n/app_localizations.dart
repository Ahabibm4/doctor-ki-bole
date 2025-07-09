import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor Ki Bole'**
  String get appTitle;

  /// No description provided for @analyzeReport.
  ///
  /// In en, this message translates to:
  /// **'Analyze Report'**
  String get analyzeReport;

  /// No description provided for @symptomChecker.
  ///
  /// In en, this message translates to:
  /// **'Symptom Checker'**
  String get symptomChecker;

  /// No description provided for @savedResults.
  ///
  /// In en, this message translates to:
  /// **'Saved Results'**
  String get savedResults;

  /// No description provided for @enterSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Enter your symptoms here...'**
  String get enterSymptoms;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No saved results yet.'**
  String get noResults;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor Ki Bole'**
  String get homeTitle;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseImageSource;

  /// No description provided for @noSavedResults.
  ///
  /// In en, this message translates to:
  /// **'No saved results yet.'**
  String get noSavedResults;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @analyzeReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan or upload report image or PDF'**
  String get analyzeReportDesc;

  /// No description provided for @symptomCheckerDesc.
  ///
  /// In en, this message translates to:
  /// **'Get GPT help for your symptoms'**
  String get symptomCheckerDesc;

  /// No description provided for @savedResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'View your previous analyses'**
  String get savedResultsDesc;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick File'**
  String get pickFile;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get useCamera;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick Image from Gallery'**
  String get pickFromGallery;

  /// No description provided for @pickPdf.
  ///
  /// In en, this message translates to:
  /// **'Pick a PDF File'**
  String get pickPdf;

  /// No description provided for @previewText.
  ///
  /// In en, this message translates to:
  /// **'Preview of extracted text'**
  String get previewText;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional Note'**
  String get optionalNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add your personal note (optional)'**
  String get noteHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noResultsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please upload a report to analyze.'**
  String get noResultsPlaceholder;

  /// No description provided for @uploadReport.
  ///
  /// In en, this message translates to:
  /// **'Upload Report'**
  String get uploadReport;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'❌ Camera permission denied.'**
  String get cameraDenied;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input.'**
  String get micPermissionDenied;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @voiceInputNotSupportedOnEmulator.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not supported on emulator or this device.'**
  String get voiceInputNotSupportedOnEmulator;

  /// No description provided for @noInternetForVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Internet is required for voice input.'**
  String get noInternetForVoiceInput;

  /// No description provided for @noInternetForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cannot analyze symptoms without internet.'**
  String get noInternetForAnalysis;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get deleteConfirm;

  /// No description provided for @tapToRetryVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Please tap the microphone again to retry.'**
  String get tapToRetryVoiceInput;

  /// No description provided for @speechRecognitionError.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition failed: {error}.'**
  String speechRecognitionError(Object error);

  /// No description provided for @toggleDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle Dark Mode'**
  String get toggleDarkMode;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'❌ File is too large (max 5MB). Please choose a smaller file.'**
  String get fileTooLarge;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
