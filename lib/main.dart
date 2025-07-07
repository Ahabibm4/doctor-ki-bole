import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/report_analyzer_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/saved_results_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env loaded successfully. Key: ${dotenv.env['GEMINI_API_KEY']}");
  } catch (e) {
    print("❌ Failed to load .env: $e");
  }

  runApp(const DoctorKiBoleApp());
}

class DoctorKiBoleApp extends StatefulWidget {
  const DoctorKiBoleApp({super.key});

  @override
  State<DoctorKiBoleApp> createState() => _DoctorKiBoleAppState();
}

class _DoctorKiBoleAppState extends State<DoctorKiBoleApp> {
  Locale _locale = const Locale('bn');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'bn' ? const Locale('en') : const Locale('bn');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Ki Bole',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bn'),
        Locale('en'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => HomeScreen(onToggleLocale: _toggleLocale),
        '/report': (_) => const ReportAnalyzerScreen(),
        '/symptoms': (_) => const SymptomCheckerScreen(),
        '/saved': (_) => const SavedResultsScreen(),
      },
    );
  }
}
