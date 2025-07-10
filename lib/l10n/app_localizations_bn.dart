// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ডাক্তার কি বলে';

  @override
  String get analyzeReport => 'রিপোর্ট বিশ্লেষণ';

  @override
  String get symptomChecker => 'লক্ষণ যাচাই';

  @override
  String get savedResults => 'সংরক্ষিত ফলাফল';

  @override
  String get enterSymptoms => 'আপনার উপসর্গ লিখুন';

  @override
  String get voiceInput => 'ভয়েস ইনপুট';

  @override
  String get check => 'চেক করুন';

  @override
  String get noResults => 'কোনো ফলাফল সংরক্ষিত নেই।';

  @override
  String get pickImage => 'ছবি বাছাই করুন';

  @override
  String get chooseSource => 'ছবির উৎস নির্বাচন করুন';

  @override
  String get camera => 'ক্যামেরা';

  @override
  String get gallery => 'গ্যালারি';

  @override
  String get homeTitle => 'ডাক্তার কি বলে';

  @override
  String get chooseImageSource => 'ছবির উৎস নির্বাচন করুন';

  @override
  String get noSavedResults => 'এখনো কোনো ফলাফল সংরক্ষিত নেই।';

  @override
  String get delete => 'মুছুন';

  @override
  String get analyzeReportDesc => 'ছবি বা পিডিএফ রিপোর্ট স্ক্যান বা আপলোড করুন';

  @override
  String get symptomCheckerDesc => 'আপনার উপসর্গের জন্য GPT সহায়তা নিন';

  @override
  String get savedResultsDesc => 'আপনার পূর্ববর্তী বিশ্লেষণগুলো দেখুন';

  @override
  String get switchLanguage => 'ভাষা পরিবর্তন করুন';

  @override
  String get pickFile => 'ফাইল বেছে নিন';

  @override
  String get useCamera => 'ক্যামেরা দিয়ে ছবি তুলুন';

  @override
  String get pickFromGallery => 'গ্যালারি থেকে ছবি বাছুন';

  @override
  String get pickPdf => 'PDF ফাইল বাছুন';

  @override
  String get previewText => 'এক্সট্রাক্ট করা টেক্সটের প্রিভিউ';

  @override
  String get optionalNote => 'ঐচ্ছিক নোট লিখুন';

  @override
  String get noteHint => 'আপনার নিজের মন্তব্য দিন (ঐচ্ছিক)';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get noResultsPlaceholder => 'বিশ্লেষণের জন্য একটি রিপোর্ট আপলোড করুন।';

  @override
  String get uploadReport => 'রিপোর্ট আপলোড করুন';

  @override
  String get cameraDenied => '❌ ক্যামেরার অনুমতি দেওয়া হয়নি।';

  @override
  String get clear => 'পরিষ্কার করুন';

  @override
  String get micPermissionDenied => 'ভয়েস ইনপুটের জন্য মাইক্রোফোন অনুমতি প্রয়োজন।';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get share => 'শেয়ার করুন';

  @override
  String get voiceInputNotSupportedOnEmulator => 'এই ডিভাইসে বা এমুলেটরে ভয়েস ইনপুট সমর্থিত নয়।';

  @override
  String get noInternetForVoiceInput => 'ভয়েস ইনপুটের জন্য ইন্টারনেট সংযোগ প্রয়োজন।';

  @override
  String get noInternetForAnalysis => 'ইন্টারনেট ছাড়া উপসর্গ বিশ্লেষণ করা সম্ভব না।';

  @override
  String get deleteConfirm => 'আপনি কি এই রেকর্ডটি মুছে ফেলতে চান?';

  @override
  String get tapToRetryVoiceInput => 'আবার চেষ্টা করতে মাইক্রোফোন আইকনে চাপ দিন।';

  @override
  String speechRecognitionError(Object error) {
    return 'ভয়েস শনাক্তকরণ ব্যর্থ হয়েছে: $error।';
  }

  @override
  String get toggleDarkMode => 'ডার্ক মোড চালু/বন্ধ করুন';

  @override
  String get fileTooLarge => '❌ ফাইলটি খুব বড় (সর্বোচ্চ ৫ এমবি)। ছোট একটি ফাইল নির্বাচন করুন।';

  @override
  String get stopListening => 'শোনা বন্ধ করুন';
}
