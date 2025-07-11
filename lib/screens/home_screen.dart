import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'result_viewer_screen.dart';
import '../l10n/app_localizations.dart';

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
              _QuickActionCard(
                emoji: '📸',
                title: loc.cameraUpload,
                subtitle: loc.cameraUploadDesc,
                color: colorScheme.primaryContainer,
                onPressed: () async {
                  final image = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    final file = File(image.path);
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ResultViewerScreen(file: file),
                      ));
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              _QuickActionCard(
                emoji: '📁',
                title: loc.uploadFile,
                subtitle: loc.uploadFileDesc,
                color: colorScheme.secondaryContainer,
                onPressed: () async {
                  final picked = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );

                  if (picked != null && picked.files.single.path != null) {
                    final file = File(picked.files.single.path!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResultViewerScreen(file: file)),
                    );
                  } else {
                    debugPrint("❌ File picker returned null");
                  }
                },
              ),
              const SizedBox(height: 20),
              _AnimatedCard(
                emoji: '🤒',
                title: loc.symptomChecker,
                subtitle: loc.symptomCheckerDesc,
                route: '/symptoms',
                color: colorScheme.tertiaryContainer,
              ),
              const SizedBox(height: 20),
              _AnimatedCard(
                emoji: '📂',
                title: loc.savedResults,
                subtitle: loc.savedResultsDesc,
                route: '/saved',
                color: colorScheme.surfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Color color;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 6,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
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
                  Text(widget.emoji, style: const TextStyle(fontSize: 40)),
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
