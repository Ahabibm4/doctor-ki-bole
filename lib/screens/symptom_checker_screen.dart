import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/gpt_service.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _symptomController.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _analyzeSymptoms() async {
    final input = _symptomController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _loading = true;
      _result = '';
    });

    final response = await _gptService.analyzeText(input);

    setState(() {
      _result = response;
      _loading = false;
    });

    await db.DBService.insertResult(
      SavedResult(
        type: 'symptom',
        input: input,
        result: response,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.symptomChecker)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _symptomController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: loc.enterSymptoms,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: Text(loc.voiceInput),
                  onPressed: _listen,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _analyzeSymptoms,
                  child: Text(loc.check),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_result.isNotEmpty)
              Expanded(child: SingleChildScrollView(child: Text(_result))),
          ],
        ),
      ),
    );
  }
}
