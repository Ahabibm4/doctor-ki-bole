import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/report_analyzer_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/saved_results_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env for API keys
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env loaded. Key: ${dotenv.env['GEMINI_API_KEY']}");
  } catch (e) {
    debugPrint("❌ Failed to load .env: $e");
  }

  // Load saved preferences
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('selected_language') ?? 'bn';
  final darkMode = prefs.getBool('dark_mode') ?? false;

  runApp(DoctorKiBoleApp(
    initialLocale: Locale(savedLang),
    initialThemeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
  ));
}

class DoctorKiBoleApp extends StatefulWidget {
  final Locale initialLocale;
  final ThemeMode initialThemeMode;

  const DoctorKiBoleApp({
    super.key,
    required this.initialLocale,
    required this.initialThemeMode,
  });

  @override
  State<DoctorKiBoleApp> createState() => _DoctorKiBoleAppState();
}

class _DoctorKiBoleAppState extends State<DoctorKiBoleApp> {
  late Locale _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleLocale() async {
    final newLang = _locale.languageCode == 'bn' ? 'en' : 'bn';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    setState(() => _locale = Locale(newLang));
  }

  Future<void> _toggleTheme() async {
    final isDark = _themeMode == ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', !isDark);
    setState(() => _themeMode = !isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Ki Bole',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      supportedLocales: const [Locale('bn'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => HomeScreen(
              onToggleLocale: _toggleLocale,
              onToggleTheme: _toggleTheme,
            ),
        '/report': (_) => const ReportAnalyzerScreen(),
        '/symptoms': (_) => const SymptomCheckerScreen(),
        '/saved': (_) => const SavedResultsScreen(),
      },
    );
  }
}
