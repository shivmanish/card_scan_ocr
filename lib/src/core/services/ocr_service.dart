import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrService {
  Future<String> extractText(String imagePath);
  Future<void> dispose();
}

class MlKitOcrService implements OcrService {
  MlKitOcrService({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> extractText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  @override
  Future<void> dispose() => _recognizer.close();
}

