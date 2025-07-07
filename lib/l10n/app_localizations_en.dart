// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Doctor Ki Bole';

  @override
  String get analyzeReport => 'Analyze Report';

  @override
  String get symptomChecker => 'Symptom Checker';

  @override
  String get savedResults => 'Saved Results';

  @override
  String get enterSymptoms => 'Enter your symptoms here...';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get check => 'Check';

  @override
  String get noResults => 'No saved results yet.';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get chooseSource => 'Choose image source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get homeTitle => 'Doctor Ki Bole';

  @override
  String get chooseImageSource => 'Choose image source';

  @override
  String get noSavedResults => 'No saved results yet.';

  @override
  String get delete => 'Delete';

  @override
  String get analyzeReportDesc => 'Scan or upload report image or PDF';

  @override
  String get symptomCheckerDesc => 'Get GPT help for your symptoms';

  @override
  String get savedResultsDesc => 'View your previous analyses';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get pickFile => 'Pick File';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get pickPdf => 'Pick a PDF File';

  @override
  String get previewText => 'Preview';

  @override
  String get optionalNote => 'Optional Note';

  @override
  String get noteHint => 'Add your personal note (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get noResultsPlaceholder => 'No results yet';

  @override
  String get uploadReport => 'Upload Image or PDF';

  @override
  String get cameraDenied => 'Camera permission was denied';

  @override
  String get clear => 'Clear';

  @override
  String get micPermissionDenied => 'Microphone permission is required for voice input.';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Share';

  @override
  String get voiceInputNotSupportedOnEmulator => 'Voice input is not supported on emulator. Please use a real device.';
}
