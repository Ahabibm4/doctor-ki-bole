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

  final source = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Choose image source"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const Text("Camera"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          child: const Text("Gallery"),
        ),
      ],
    ),
  );

  if (source != null) {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _loading = true;
        _result = '';
      });

      // Simulate OCR + GPT
      await Future.delayed(const Duration(seconds: 2));
      final fakeText = "Hemoglobin: 10.5 g/dL";
      final fakeGptResponse = "Mild anemia detected. Please consult a doctor.";

      setState(() {
        _result = fakeGptResponse;
        _loading = false;
      });
    }
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
