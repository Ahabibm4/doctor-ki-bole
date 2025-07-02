import 'dart:convert';
import 'package:http/http.dart' as http;

class GptService {
  final String _spaceUrl = 'https://yuntian-deng-chatgpt4.hf.space/run/predict';

  Future<String> analyzeText(String inputText) async {
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "data": [inputText]  // Hugging Face Space format
    });

    try {
      final response = await http.post(
        Uri.parse(_spaceUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final generatedText = result['data'][0];
        return generatedText.toString();
      } else {
        return "❌ API Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "❌ Request failed: $e";
    }
  }
}
