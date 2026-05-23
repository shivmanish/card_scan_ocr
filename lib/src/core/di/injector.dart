import 'package:get_it/get_it.dart';

import '../../features/card_scanner/data/datasource/card_scanner_datasource.dart';
import '../../features/card_scanner/data/repository_impl/card_scanner_repository_impl.dart';
import '../../features/card_scanner/domain/repository/card_scanner_repository.dart';
import '../../features/card_scanner/domain/usecases/scan_card_usecase.dart';
import '../../features/passbook_scanner/data/datasource/passbook_scanner_datasource.dart';
import '../../features/passbook_scanner/data/repository_impl/passbook_scanner_repository_impl.dart';
import '../../features/passbook_scanner/domain/repository/passbook_scanner_repository.dart';
import '../../features/passbook_scanner/domain/usecases/scan_passbook_usecase.dart';
import '../services/image_picker_service.dart';
import '../services/ocr_service.dart';

final sl = GetIt.instance;

/// Composition root. This file is the one place that's allowed to know about
/// every layer — it wires them together.
Future<void> initInjector() async {
  _registerCoreServices();
  _registerCardScanner();
  _registerPassbookScanner();
}

void _registerCoreServices() {
  sl.registerLazySingleton<OcrService>(MlKitOcrService.new);
  sl.registerLazySingleton<ImagePickerService>(ImagePickerServiceImpl.new);
}

void _registerCardScanner() {
  sl
    ..registerLazySingleton<CardScannerDataSource>(
      () => CardScannerDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CardScannerRepository>(
      () => CardScannerRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => ScanCardUseCase(sl()));
}

void _registerPassbookScanner() {
  sl
    ..registerLazySingleton<PassbookScannerDataSource>(
      () => PassbookScannerDataSourceImpl(sl()),
    )
    ..registerLazySingleton<PassbookScannerRepository>(
      () => PassbookScannerRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => ScanPassbookUseCase(sl()));
}
