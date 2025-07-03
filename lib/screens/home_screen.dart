import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleLocale;
  const HomeScreen({super.key, required this.onToggleLocale});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: Text(isBangla ? '🇬🇧' : '🇧🇩', style: const TextStyle(fontSize: 20)),
            tooltip: 'Switch Language',
            onPressed: onToggleLocale,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/report'),
              child: Text(loc.analyzeReport),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/symptoms'),
              child: Text(loc.symptomChecker),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/saved'),
              child: Text(loc.savedResults),
            ),
          ],
        ),
      ),
    );
  }
}
