import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static Future<String> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    // Google ML Kit does NOT support Bangla script officially.
    // Use Latin script (works partially for printed Bangla text).
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      // Log or handle error
      return '';
    } finally {
      await textRecognizer.close();
    }
  }
}
