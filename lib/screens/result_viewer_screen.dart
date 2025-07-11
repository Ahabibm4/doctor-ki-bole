import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../services/ocr_service.dart';
import '../services/pdf_service.dart';
import '../services/gpt_service.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';
import '../l10n/app_localizations.dart';

class ResultViewerScreen extends StatefulWidget {
  final File file;

  const ResultViewerScreen({super.key, required this.file});

  @override
  State<ResultViewerScreen> createState() => _ResultViewerScreenState();
}

class _ResultViewerScreenState extends State<ResultViewerScreen> {
  final _gptService = GptService();
  bool _loading = true;
  String _ocrText = '';
  String _gptResult = '';

  @override
  void initState() {
    super.initState();
    _analyzeFile(widget.file);
  }

  Future<void> _analyzeFile(File file) async {
    final loc = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final gptLang = langCode == 'en' ? GptLanguage.en : GptLanguage.bn;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        _setError(loc.noInternet);
        return;
      }

      String extractedText = '';
      if (file.path.toLowerCase().endsWith('.pdf')) {
        final bytes = await file.readAsBytes();
        final doc = PdfDocument(inputBytes: bytes);
        extractedText = PdfTextExtractor(doc).extractText();
        doc.dispose();
      } else {
        extractedText = await OCRService.extractTextFromImage(file);
      }

      if (extractedText.trim().isEmpty) {
        _setError(loc.noTextFound);
        return;
      }

      final gptResponse = await _gptService.generateResponse(
        extractedText,
        type: GptPromptType.report,
        lang: gptLang,
      );

      final fallback = gptLang == GptLanguage.en
          ? loc.fallbackMessageEn
          : loc.fallbackMessageBn;

      final finalText = gptResponse.trim().isEmpty || gptResponse.startsWith('❌')
          ? fallback
          : gptResponse;

      await db.DBService.insertResult(SavedResult(
        type: 'report',
        input: extractedText,
        result: finalText,
        timestamp: DateTime.now(),
      ));

      setState(() {
        _ocrText = extractedText;
        _gptResult = finalText;
        _loading = false;
      });
    } catch (e) {
      _setError(loc.errorProcessing);
    }
  }

  void _setError(String message) {
    setState(() {
      _ocrText = '';
      _gptResult = message;
      _loading = false;
    });
  }

  void _retry() {
    setState(() {
      _loading = true;
    });
    _analyzeFile(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.resultTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📎 ${widget.file.path.split('/').last}",
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),

                  if (_ocrText.isNotEmpty) ...[
                    Text("🧾 ${loc.extractedText}", style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(_ocrText),
                    const SizedBox(height: 24),
                  ],

                  Text("🤖 ${loc.geminiResult}", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(_gptResult),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.autoSaved),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Share.share(_gptResult),
                        icon: const Icon(Icons.share),
                        label: Text(loc.share),
                      ),
                      ElevatedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.retry),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
