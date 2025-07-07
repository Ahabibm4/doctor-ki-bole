import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptService {
  final _apiKey = dotenv.env['GEMINI_API_KEY'];
  static const _model = 'gemini-2.0-flash';

  Future<String> generateResponse(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "আপনি একজন বন্ধুসুলভ স্বাস্থ্য সহকারী। এখন ব্যাখ্যা করুন:\n$text"}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? '⚠️ No response';
    } else {
      return "❌ API error ${response.statusCode}: ${response.body}";
    }
  }
}
