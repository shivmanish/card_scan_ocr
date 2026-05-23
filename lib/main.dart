import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/di/injector.dart';
import 'src/core/services/ocr_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjector();
  WidgetsBinding.instance.addObserver(_OcrLifecycleDisposer());
  runApp(const CardScanOcrApp());
}

/// Best-effort: dispose the ML Kit `TextRecognizer` when the app is being
/// torn down so its native handle is released. On Android, `detached` is
/// fired briefly before process exit; if the OS force-kills the process we
/// rely on the OS reclaiming native resources.
class _OcrLifecycleDisposer extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      sl<OcrService>().dispose();
    }
  }
}
