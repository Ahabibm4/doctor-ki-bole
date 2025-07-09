import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  bool _uploading = false;

  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB

  String _applyFallback(String response, GptLanguage lang) {
    final fallback = lang == GptLanguage.en
        ? "⚠️ AI assistant is not available now. Please try again later."
        : "⚠️ এই মুহূর্তে AI সহকারী সাড়া দিচ্ছে না। একটু পর আবার চেষ্টা করুন।";
    return response.trim().isEmpty || response.startsWith('❌') ? fallback : response;
  }

  Future<void> _pickFile() async {
    final loc = AppLocalizations.of(context)!;

    setState(() => _uploading = true);

    final choice = await showModalBottomSheet<String>(
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

    File? pickedFile;

    try {
      if (choice == 'camera') {
        if (!await Permission.camera.request().isGranted) {
          _showError(loc.cameraDenied);
          return;
        }
        final image = await ImagePicker().pickImage(source: ImageSource.camera);
        if (image != null) pickedFile = File(image.path);
      } else if (choice == 'gallery') {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) pickedFile = File(image.path);
      } else if (choice == 'pdf') {
        final file = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
        if (file?.files.single.path != null) pickedFile = File(file!.files.single.path!);
      }

      if (pickedFile == null) return;

      if (await pickedFile.length() > _maxFileSize) {
        _showError(loc.fileTooLarge);
        return;
      }

      if (pickedFile.path.toLowerCase().endsWith('.pdf')) {
        await _processPdf(pickedFile);
      } else {
        await _processImage(pickedFile);
      }
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _processImage(File file) async {
    setState(() {
      _loading = true;
      _selectedFile = file;
      _result = '';
      _previewText = '';
    });

    final extractedText = await OCRService.extractTextFromImage(file);
    if (extractedText.trim().isEmpty) {
      setState(() => _loading = false);
      _showError("❌ Couldn’t extract text. Try with a clearer photo.");
      return;
    }

    await _analyzeText(extractedText);
  }

  Future<void> _processPdf(File file) async {
    setState(() {
      _loading = true;
      _selectedFile = file;
      _result = '';
      _previewText = '';
    });

    try {
      final bytes = await file.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final extractedText = PdfTextExtractor(doc).extractText();
      doc.dispose();

      if (extractedText.trim().isEmpty) {
        setState(() => _loading = false);
        _showError("❌ PDF contains no readable text.");
        return;
      }

      await _analyzeText(extractedText);
    } catch (e) {
      setState(() => _loading = false);
      _showError("❌ Failed to process PDF: $e");
    }
  }

  Future<void> _analyzeText(String inputText) async {
    final langCode = Localizations.localeOf(context).languageCode;
    final gptLang = langCode == 'en' ? GptLanguage.en : GptLanguage.bn;
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      setState(() => _loading = false);
      _showError("❌ No internet connection.");
      return;
    }

    final gptResponse = await _gptService.generateResponse(
      inputText,
      type: GptPromptType.report,
      lang: gptLang,
    );

    final finalText = _applyFallback(gptResponse, gptLang);

    setState(() {
      _previewText = inputText.length > 500 ? '${inputText.substring(0, 500)}...' : inputText;
      _result = finalText;
      _loading = false;
    });

    await db.DBService.insertResult(SavedResult(
      type: 'report',
      input: inputText,
      result: finalText,
      timestamp: DateTime.now(),
    ));
  }

  void _clear() {
    setState(() {
      _selectedFile = null;
      _result = '';
      _previewText = '';
    });
  }

  void _retry() {
    if (_selectedFile == null) return;
    final ext = _selectedFile!.path.split('.').last.toLowerCase();
    ext == 'pdf' ? _processPdf(_selectedFile!) : _processImage(_selectedFile!);
  }

  void _shareResult() {
    if (_result.isNotEmpty) {
      Share.share(_result, subject: "Doctor Ki Bole - Report Summary");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.analyzeReport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(loc.uploadReport),
                    onPressed: _uploading ? null : _pickFile,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ),
                if (_uploading)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              if (_selectedFile!.path.toLowerCase().endsWith('.jpg') || _selectedFile!.path.toLowerCase().endsWith('.png'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_selectedFile!, height: 180, fit: BoxFit.cover),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "📎 ${_selectedFile!.path.split('/').last}",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ),
            ],
            if (_previewText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("📄 ${loc.previewText}\n\n$_previewText", style: textTheme.bodyMedium),
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
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Text(_result, style: textTheme.bodyLarge),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                        ),
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
                child: Text(loc.noResultsPlaceholder, style: textTheme.bodyLarge),
              ),
          ],
        ),
      ),
    );
  }
}
