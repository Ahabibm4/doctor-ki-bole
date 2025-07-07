import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Prompt type to customize language model response
enum GptPromptType { symptom, report }

/// Supported output languages
enum GptLanguage { bn, en }

/// Gemini-powered GPT service for healthcare explanations
class GptService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  static const String _model = 'gemini-2.0-flash';
  final Duration _timeout = Duration(seconds: 15);

  /// Generates a Gemini response for a given input and context
  Future<String> generateResponse(
    String userInput, {
    GptPromptType type = GptPromptType.report,
    GptLanguage lang = GptLanguage.bn,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return '❌ Gemini API key not configured.';
    }

    final prompt = _buildPrompt(userInput, type: type, lang: lang);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? '⚠️ Gemini returned an empty response.';
      } else {
        return "❌ API error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "❌ Request failed: $e";
    }
  }

  /// Builds the prompt string with role, tone, and output language
  String _buildPrompt(
    String input, {
    required GptPromptType type,
    required GptLanguage lang,
  }) {
    if (lang == GptLanguage.en) {
      switch (type) {
        case GptPromptType.symptom:
          return '''
You are a friendly Bangladeshi health assistant. Based on the symptoms below:

✅ Instructions:
- Respond in simple English a 10-year-old could understand
- Do NOT use medical jargon
- Do NOT suggest medication or diagnosis
- Be warm, kind, and non-alarming
- Use bullet points where helpful

Symptoms:
$input
''';
        case GptPromptType.report:
          return '''
You are a friendly Bangladeshi virtual health assistant. Your task is to explain this medical test report clearly to a non-medical person.

✅ Guidelines:
- Use plain, conversational English
- Break down complex terms simply
- Highlight any abnormal points
- Use bullet points if helpful
- Avoid diagnosing or giving treatment advice

Report:
$input
''';
      }
    } else {
      switch (type) {
        case GptPromptType.symptom:
          return '''
আপনি একজন বন্ধুসুলভ স্বাস্থ্য সহকারী, তবে চিকিৎসক নন। নিচের উপসর্গ দেখে সহজ বাংলায় ব্যাখ্যা দিন।

✅ নির্দেশনা:
- কঠিন মেডিকেল শব্দ ব্যবহার করবেন না
- সহজ ও সাহসজাগানিয়া ভাষায় লিখুন
- ওষুধ বা চিকিৎসা পরামর্শ দেবেন না
- প্রয়োজনে পয়েন্ট আকারে লিখুন

উপসর্গ:
$input
''';
        case GptPromptType.report:
          return '''
আপনি একজন বন্ধুসুলভ স্বাস্থ্য সহকারী। নিচের মেডিকেল রিপোর্টটি ব্যাখ্যা করুন যেন একজন সাধারণ মানুষ সহজে বুঝতে পারে।

✅ নির্দেশনা:
- কঠিন মেডিকেল টার্ম বাদ দিয়ে সহজ ভাষা ব্যবহার করুন
- অস্বাভাবিক কিছু থাকলে আলাদা করে বলুন
- রোগ নির্ণয় বা চিকিৎসা পরামর্শ দিবেন না
- প্রয়োজন হলে পয়েন্ট আকারে ব্যাখ্যা দিন

রিপোর্ট:
$input
''';
      }
    }
  }
}
