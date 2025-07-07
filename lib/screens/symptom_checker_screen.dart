import 'dart:io';
import 'package:doctor_ki_bole/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';

import '../services/gpt_service.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final _gptService = GptService();
  String _result = '';
  bool _loading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    final loc = AppLocalizations.of(context)!;

    if (Platform.isAndroid && !await _speech.hasPermission) {
      bool permission = await _speech.initialize();
      if (!permission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.micPermissionDenied)),
        );
        return;
      }
    }

    if (!await _speech.initialize()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.voiceInputNotSupportedOnEmulator)),
      );
      return;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _symptomController.text = val.recognizedWords;
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _analyzeSymptoms() async {
    final loc = AppLocalizations.of(context)!;
    final input = _symptomController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.enterSymptoms)),
      );
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final langCode = Localizations.localeOf(context).languageCode;
      final gptLang = langCode == 'en' ? GptLanguage.en : GptLanguage.bn;

      final response = await _gptService.generateResponse(
        input,
        type: GptPromptType.symptom,
        lang: gptLang,
      );

      final fallbackMessage = gptLang == GptLanguage.en
          ? "⚠️ AI assistant is not available now. Please try again later."
          : "⚠️ এ moment-এ AI সহকারী সাড়া দিচ্ছে না। একটু পর আবার চেষ্টা করুন।";

      final finalOutput = response.trim().isEmpty || response.startsWith('❌')
          ? fallbackMessage
          : response;

      setState(() {
        _result = finalOutput;
        _loading = false;
      });

      await db.DBService.insertResult(
        SavedResult(
          type: 'symptom',
          input: input,
          result: finalOutput,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      final fallback = Localizations.localeOf(context).languageCode == 'bn'
          ? "⚠️ অনুগ্রহ করে পরে আবার চেষ্টা করুন।"
          : "⚠️ Something went wrong. Please try again later.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallback)));
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                decoration: InputDecoration(
                  labelText: loc.enterSymptoms,
                  hintText: loc.enterSymptoms,
                  prefixIcon: const Icon(Icons.health_and_safety),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _symptomController.clear(),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    label: Text(loc.voiceInput),
                    onPressed: _listen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: Text(loc.check),
                    onPressed: _analyzeSymptoms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_result.isNotEmpty)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.clear),
                      onPressed: _clearAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (_result.isNotEmpty)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: Text(loc.retry),
                      onPressed: _analyzeSymptoms,
                    ),
                  if (_result.isNotEmpty)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: Text(loc.share),
                      onPressed: _shareResult,
                    ),
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
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Text(
                                  _result,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              loc.noResultsPlaceholder,
                              style: const TextStyle(color: Colors.grey),
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
