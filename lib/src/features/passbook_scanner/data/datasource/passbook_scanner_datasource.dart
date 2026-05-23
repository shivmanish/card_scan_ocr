import '../../../../core/services/ocr_service.dart';

abstract class PassbookScannerDataSource {
  Future<String> getRawText(String imagePath);
}

class PassbookScannerDataSourceImpl implements PassbookScannerDataSource {
  PassbookScannerDataSourceImpl(this.ocrService);

  final OcrService ocrService;

  @override
  Future<String> getRawText(String imagePath) =>
      ocrService.extractText(imagePath);
}
