import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/gpt_service.dart';
import '../services/ocr_service.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';

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

  Future<void> _pickImageOrPdf() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select file type"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: const Text("📸 Camera"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: const Text("🖼️ Gallery"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'pdf'),
            child: const Text("📄 PDF"),
          ),
        ],
      ),
    );

    if (option == 'camera') {
      bool granted = await _requestCameraPermission();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null) {
        final file = File(picked.path);
        await _processImage(file);
      }
    } else if (option == 'gallery') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        await _processImage(file);
      }
    } else if (option == 'pdf') {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (picked != null && picked.files.single.path != null) {
        final file = File(picked.files.single.path!);
        await _processPdf(file);
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _selectedFile = imageFile;
      _loading = true;
      _result = '';
      _previewText = '';
    });

    final ocrText = await OCRService.extractTextFromImage(imageFile);
    final response = await _gptService.generateResponse(ocrText);

    setState(() {
      _result = response;
      _loading = false;
      _previewText = ocrText;
    });

    await db.DBService.insertResult(
      SavedResult(
        type: 'report',
        input: ocrText,
        result: response,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _processPdf(File pdfFile) async {
    setState(() {
      _selectedFile = pdfFile;
      _loading = true;
      _result = '';
      _previewText = '';
    });

    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();

      final response = await _gptService.generateResponse(text);

      setState(() {
        _result = response;
        _loading = false;
        _previewText = text.length > 500 ? text.substring(0, 500) + "..." : text;
      });

      await db.DBService.insertResult(
        SavedResult(
          type: 'report',
          input: text,
          result: response,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to read PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🩺 Analyze Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Pick Image or PDF'),
              onPressed: _pickImageOrPdf,
            ),
            const SizedBox(height: 10),
            if (_previewText.isNotEmpty)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: Text(
                  "📄 Preview:\n$_previewText",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_result.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
