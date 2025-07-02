import 'dart:convert';
import 'package:http/http.dart' as http;

class GptService {
  static const _apiKey = ''; // 🔁 Replace with your real API key
  static const _model = 'gemini-2.0-flash'; // You can also use 'gemini-pro'

  Future<String> analyzeText(String text) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey');

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "আপনি একজন বন্ধুসুলভ স্বাস্থ্য সহকারী। এখন ব্যাখ্যা করুন:\n$text"}
          ]
        }
      ]
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generated = data['candidates'][0]['content']['parts'][0]['text'];
        return generated.trim();
      } else {
        return "❌ Gemini API Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "❌ Request failed: $e";
    }
  }
}
