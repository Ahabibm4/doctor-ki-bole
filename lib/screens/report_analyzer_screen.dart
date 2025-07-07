import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/gpt_service.dart';
import '../services/ocr_service.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';
import '../l10n/app_localizations.dart';

class ReportAnalyzerScreen extends StatefulWidget {
  const ReportAnalyzerScreen({super.key});

  @override
  State<ReportAnalyzerScreen> createState() => _ReportAnalyzerScreenState();
}

class _ReportAnalyzerScreenState extends State<ReportAnalyzerScreen> {
  final _gptService = GptService();
  File? _selectedFile;
  String _result = '';
  String _previewText = '';
  bool _loading = false;

  String _applyFallback(String response, GptLanguage lang) {
    final fallback = lang == GptLanguage.en
        ? "⚠️ AI assistant is not available now. Please try again later."
        : "⚠️ এই মুহূর্তে AI সহকারী সাড়া দিচ্ছে না। একটু পর আবার চেষ্টা করুন।";
    return response.trim().isEmpty || response.startsWith('❌') ? fallback : response;
  }

  Future<void> _pickImageOrPdf() async {
    final loc = AppLocalizations.of(context)!;

    final option = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(loc.useCamera),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(loc.pickFromGallery),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(loc.pickPdf),
            onTap: () => Navigator.pop(context, 'pdf'),
          ),
        ],
      ),
    );

    if (option == 'camera') {
      final granted = await Permission.camera.request();
      if (!granted.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.cameraDenied)),
        );
        return;
      }
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null) await _processImage(File(picked.path));
    } else if (option == 'gallery') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) await _processImage(File(picked.path));
    } else if (option == 'pdf') {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (picked != null && picked.files.single.path != null) {
        await _processPdf(File(picked.files.single.path!));
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _loading = true;
      _result = '';
      _previewText = '';
      _selectedFile = imageFile;
    });

    final text = await OCRService.extractTextFromImage(imageFile);

    final langCode = Localizations.localeOf(context).languageCode;
    final gptLang = langCode == 'en' ? GptLanguage.en : GptLanguage.bn;

    final rawResponse = await _gptService.generateResponse(
      text,
      type: GptPromptType.report,
      lang: gptLang,
    );

    final gptOutput = _applyFallback(rawResponse, gptLang);

    setState(() {
      _previewText = text;
      _result = gptOutput;
      _loading = false;
    });

    await db.DBService.insertResult(
      SavedResult(
        type: 'report',
        input: text,
        result: gptOutput,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _processPdf(File pdfFile) async {
    setState(() {
      _loading = true;
      _result = '';
      _previewText = '';
      _selectedFile = pdfFile;
    });

    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();

      final langCode = Localizations.localeOf(context).languageCode;
      final gptLang = langCode == 'en' ? GptLanguage.en : GptLanguage.bn;

      final rawResponse = await _gptService.generateResponse(
        text,
        type: GptPromptType.report,
        lang: gptLang,
      );

      final gptOutput = _applyFallback(rawResponse, gptLang);

      setState(() {
        _previewText = text.length > 500 ? '${text.substring(0, 500)}...' : text;
        _result = gptOutput;
        _loading = false;
      });

      await db.DBService.insertResult(
        SavedResult(
          type: 'report',
          input: text,
          result: gptOutput,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to process PDF: $e")),
      );
    }
  }

  void _clear() {
    setState(() {
      _selectedFile = null;
      _result = '';
      _previewText = '';
    });
  }

  void _retry() async {
    if (_selectedFile == null) return;

    final ext = _selectedFile!.path.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      await _processPdf(_selectedFile!);
    } else {
      await _processImage(_selectedFile!);
    }
  }

  void _shareResult() {
    if (_result.isNotEmpty) {
      Share.share(_result, subject: "Doctor Ki Bole - Report Summary");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.analyzeReport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(loc.uploadReport),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              onPressed: _pickImageOrPdf,
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              if (_selectedFile!.path.endsWith('.jpg') || _selectedFile!.path.endsWith('.png'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedFile!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "📎 ${_selectedFile!.path.split('/').last}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_previewText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("📄 ${loc.previewText}\n\n$_previewText", style: const TextStyle(fontSize: 14)),
              ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Text(_result, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.clear),
                        onPressed: _clear,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.replay),
                        label: Text(loc.retry),
                        onPressed: _retry,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: Text(loc.share),
                        onPressed: _shareResult,
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Text(loc.noResultsPlaceholder, style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
