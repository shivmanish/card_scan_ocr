import 'package:get_it/get_it.dart';

import '../services/image_picker_service.dart';
import '../services/ocr_service.dart';

final sl = GetIt.instance;

/// Composition root. This file is the one place that's allowed to know about
/// every layer — it wires them together. Feature registrations are appended
/// here as features come online.
Future<void> initInjector() async {
  _registerCoreServices();
}

void _registerCoreServices() {
  sl.registerLazySingleton<OcrService>(MlKitOcrService.new);
  sl.registerLazySingleton<ImagePickerService>(ImagePickerServiceImpl.new);
}
