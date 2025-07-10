import 'package:flutter/material.dart';
import 'package:doctor_ki_bole/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onToggleLocale,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: loc.toggleDarkMode,
            onPressed: onToggleTheme,
          ),
          IconButton(
            icon: Text(isBangla ? '🇬🇧' : '🇧🇩', style: const TextStyle(fontSize: 22)),
            tooltip: isBangla ? "Switch to English" : "বাংলা ভাষায় যান",
            onPressed: onToggleLocale,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AnimatedCard(
                emoji: '📝',
                title: loc.analyzeReport,
                subtitle: loc.analyzeReportDesc,
                route: '/report',
                color: colorScheme.primaryContainer,
              ),
              const SizedBox(height: 20),
              _AnimatedCard(
                emoji: '🤒',
                title: loc.symptomChecker,
                subtitle: loc.symptomCheckerDesc,
                route: '/symptoms',
                color: colorScheme.secondaryContainer,
              ),
              const SizedBox(height: 20),
              _AnimatedCard(
                emoji: '📂',
                title: loc.savedResults,
                subtitle: loc.savedResultsDesc,
                route: '/saved',
                color: colorScheme.tertiaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String route;
  final Color color;

  const _AnimatedCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  double _scale = 1.0;

  void _navigate() => Navigator.pushNamed(context, widget.route);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: _navigate,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 6,
          color: widget.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.black12,
            onTap: _navigate,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Semantics(
                    label: widget.title,
                    child: Hero(
                      tag: widget.route,
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
