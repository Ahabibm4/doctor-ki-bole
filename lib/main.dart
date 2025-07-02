import 'package:doctor_ki_bole/screens/report_analyzer_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/symptom_checker_screen.dart';

void main() {
  runApp(const DoctorKiBoleApp());
}

class DoctorKiBoleApp extends StatelessWidget {
  const DoctorKiBoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inside DoctorKiBoleApp
    return MaterialApp(
      title: 'Doctor Ki Bole',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
      routes: {
        '/report': (context) => const ReportAnalyzerScreen(),
        '/symptoms': (context) => const SymptomCheckerScreen(),
      },
    );

  }
}