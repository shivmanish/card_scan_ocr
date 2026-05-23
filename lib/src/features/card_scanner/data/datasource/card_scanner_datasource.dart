import '../../../../core/services/ocr_service.dart';

abstract class CardScannerDataSource {
  Future<String> getRawText(String imagePath);
}

class CardScannerDataSourceImpl implements CardScannerDataSource {
  CardScannerDataSourceImpl(this.ocrService);

  final OcrService ocrService;

  @override
  Future<String> getRawText(String imagePath) =>
      ocrService.extractText(imagePath);
}
