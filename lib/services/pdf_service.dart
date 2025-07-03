import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  /// Opens file picker, loads the PDF, and returns extracted text.
  static Future<String?> pickAndExtractText() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        final text = PdfTextExtractor(document).extractText();
        document.dispose();
        return text;
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Failed to read PDF: $e");
      return null;
    }
  }
}
