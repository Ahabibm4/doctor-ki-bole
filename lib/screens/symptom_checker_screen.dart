import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/gpt_service.dart';

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
      print("🎙 Initializing speech...");
      bool available = await _speech.initialize();
      if (available) {
        print("🎙 Listening...");
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          print("🎤 You said: ${val.recognizedWords}");
          setState(() {
            _symptomController.text = val.recognizedWords;
          });
        });
      } else {
        print("❌ Speech recognition not available.");
      }
    } else {
      print("🛑 Stopping listening...");
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

    print("🧠 Sending to GPT: $input");

    final response = await _gptService.analyzeText(input);

    setState(() {
      _result = response;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Symptom Checker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _symptomController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Enter your symptoms',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: const Text("Voice Input"),
                  onPressed: _listen,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _analyzeSymptoms,
                  child: const Text("Check"),
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
