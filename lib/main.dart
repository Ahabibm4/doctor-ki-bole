import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/report_analyzer_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/saved_results_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const DoctorKiBoleApp());
}

class DoctorKiBoleApp extends StatefulWidget {
  const DoctorKiBoleApp({super.key});

  @override
  State<DoctorKiBoleApp> createState() => _DoctorKiBoleAppState();
}

class _DoctorKiBoleAppState extends State<DoctorKiBoleApp> {
  Locale _locale = const Locale('bn'); // default to Bangla

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
