import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/gpt_service.dart';
import '../services/db_service.dart' as db;
import '../services/voice_service.dart';
import '../models/saved_result.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final _gptService = GptService();
  final _voiceService = VoiceService();

  String _result = '';
  bool _loading = false;
  bool _isListening = false;
  double _waveHeight = 10.0;

  String _applyFallback(String response, GptLanguage lang) {
    final fallback = lang == GptLanguage.en
        ? "⚠️ AI assistant is not available now. Please try again later."
        : "⚠️ এই মুহূর্তে AI সহকারী সাড়া দিচ্ছে না। একটু পর আবার চেষ্টা করুন।";
    return response.trim().isEmpty || response.startsWith('❌') ? fallback : response;
  }

  Future<void> _listen() async {
    final loc = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      _showMessage("❌ ${loc.noInternetForVoiceInput}");
      return;
    }

    if (_isListening) {
      _stopListeningUI();
      _voiceService.stopListening();
      return;
    }

    final available = await _voiceService.init(
      onError: (msg) {
        _stopListeningUI();
        _voiceService.stopListening();
        _showMessage("❌ $msg\n${loc.tapToRetryVoiceInput}");
      },
    );

    if (!available) {
      _showMessage("❌ ${loc.voiceInputNotSupportedOnEmulator}");
      return;
    }

    setState(() {
      _isListening = true;
      _waveHeight = 20.0;
    });

    _voiceService.startListening(
      langCode: langCode,
      onResult: (recognizedText) {
        setState(() {
          _symptomController.text = recognizedText;
        });
      },
    );
  }

  void _stopListeningUI() {
    setState(() {
      _isListening = false;
      _waveHeight = 10.0;
    });
  }

  Future<void> _analyzeSymptoms() async {
    final loc = AppLocalizations.of(context)!;
    final input = _symptomController.text.trim();
    if (input.isEmpty) {
      _showMessage(loc.enterSymptoms);
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      _showMessage("❌ ${loc.noInternetForAnalysis}");
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final lang = Localizations.localeOf(context).languageCode == 'en'
          ? GptLanguage.en
          : GptLanguage.bn;

      final response = await _gptService.generateResponse(
        input,
        type: GptPromptType.symptom,
        lang: lang,
      );

      final finalOutput = _applyFallback(response, lang);

      setState(() {
        _result = finalOutput;
        _loading = false;
      });

      await db.DBService.insertResult(SavedResult(
        type: 'symptom',
        input: input,
        result: finalOutput,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      setState(() => _loading = false);
      final fallback = Localizations.localeOf(context).languageCode == 'bn'
          ? "⚠️ অনুগ্রহ করে পরে আবার চেষ্টা করুন।"
          : "⚠️ Something went wrong. Please try again later.";
      _showMessage(fallback);
    }
  }

  void _clearAll() {
    setState(() {
      _symptomController.clear();
      _result = '';
    });
  }

  void _shareResult() {
    if (_result.isNotEmpty) {
      Share.share(_result, subject: "Doctor Ki Bole - Symptom Analysis");
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.symptomChecker)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _symptomController,
                maxLines: 3,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: loc.enterSymptoms,
                  prefixIcon: const Icon(Icons.health_and_safety),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearAll,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isListening)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: _waveHeight,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onEnd: () {
                    if (_isListening) {
                      setState(() {
                        _waveHeight = _waveHeight == 10 ? 20 : 10;
                      });
                    }
                  },
                ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    label: Text(loc.voiceInput),
                    onPressed: _listen,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: Text(loc.check),
                    onPressed: _analyzeSymptoms,
                  ),
                  if (_result.isNotEmpty) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.clear),
                      onPressed: _clearAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: Text(loc.retry),
                      onPressed: _analyzeSymptoms,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: Text(loc.share),
                      onPressed: _shareResult,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _result.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Text(_result, style: theme.textTheme.bodyLarge),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              loc.noResultsPlaceholder,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
