import 'package:flutter/material.dart';
import 'package:doctor_ki_bole/l10n/app_localizations.dart';

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
        centerTitle: true,
        actions: [
          IconButton(
            icon: Text(isBangla ? '🇬🇧' : '🇧🇩', style: const TextStyle(fontSize: 22)),
            tooltip: loc.switchLanguage,
            onPressed: onToggleLocale,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCard(
              context,
              icon: Icons.upload_file,
              title: loc.analyzeReport,
              subtitle: loc.analyzeReportDesc,
              route: '/report',
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              icon: Icons.healing,
              title: loc.symptomChecker,
              subtitle: loc.symptomCheckerDesc,
              route: '/symptoms',
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              icon: Icons.history,
              title: loc.savedResults,
              subtitle: loc.savedResultsDesc,
              route: '/saved',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required String route}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.teal.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
