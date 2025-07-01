import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportAnalyzerScreen extends StatefulWidget {
  const ReportAnalyzerScreen({super.key});

  @override
  State<ReportAnalyzerScreen> createState() => _ReportAnalyzerScreenState();
}

class _ReportAnalyzerScreenState extends State<ReportAnalyzerScreen> {
  File? _selectedImage;
  String _result = '';
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _loading = true;
      });

      // Dummy OCR + GPT simulation
      await Future.delayed(const Duration(seconds: 2));
      final fakeText = "Hemoglobin: 10.5 g/dL\nWBC: 7.2 x10^9/L";
      final fakeGptResponse = "The report shows mild anemia. Consult a doctor if symptoms persist.";

      setState(() {
        _result = fakeGptResponse;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyze Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null) Image.file(_selectedImage!, height: 200),
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
