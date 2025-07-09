import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  Function(String)? _onError;

  /// Initializes the speech recognition service
  Future<bool> init({Function(String)? onError}) async {
    _onError = onError;
    final available = await _speech.initialize(debugLogging: false);
    if (!available) {
      _onError?.call("⚠️ Speech recognition is not available.");
    }
    return available;
  }

  /// Starts listening with correct options for v7.1.0
  void startListening({
    required String langCode,
    required Function(String) onResult,
    Function(double)? onSoundLevelChange,
  }) {
    if (!_speech.isAvailable) {
      _onError?.call("❌ Speech recognition not available.");
      return;
    }

    final options = SpeechListenOptions(
      partialResults: true,
      cancelOnError: true,
    );

    _speech.listen(
      localeId: langCode == 'bn' ? 'bn_BD' : 'en_US',
      onResult: (result) => onResult(result.recognizedWords),
      onSoundLevelChange: onSoundLevelChange ?? (_) {},
      listenOptions: options,
    );
  }

  /// Attaches a global error listener (must be set after `initialize()`)
  void setErrorHandler(Function(String) onErrorCallback) {
    _speech.errorListener = (error) {
      if (error.errorMsg.contains('speech_timeout')) {
        onErrorCallback("⏱️ Timeout! Please speak louder or retry.");
      } else {
        onErrorCallback("❌ ${error.errorMsg}");
      }
      stopListening();
    };
  }

  void stopListening() {
    _speech.stop();
  }

  void cancelListening() {
    _speech.cancel();
  }

  bool get isListening => _speech.isListening;

  bool get isAvailable => _speech.isAvailable;

  Future<bool> hasPermission() async => await _speech.hasPermission;
}
