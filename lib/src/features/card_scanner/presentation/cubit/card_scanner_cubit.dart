import '../../../../core/cubit/base_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../domain/entities/card_details.dart';
import '../../domain/usecases/scan_card_usecase.dart';
import 'card_scanner_state.dart';

class CardScannerCubit
    extends BaseCubit<CardScannerState, CardDetails, ScanCardParams> {
  CardScannerCubit({
    required ScanCardUseCase scanCardUseCase,
    required this.imagePickerService,
  }) : super(
          initialState: const CardScannerInitial(),
          useCase: scanCardUseCase,
        );

  final ImagePickerService imagePickerService;

  Future<void> pickAndScan(ImageSourceType source) async {
    if (state is CardScannerLoading) return;

    final String? picked;
    try {
      picked = await imagePickerService.pickImage(source);
    } catch (_) {
      safeEmit(
        const CardScannerFailure(
          failure: PermissionFailure(
            'Could not access the image. Check app permissions.',
          ),
        ),
      );
      return;
    }
    if (picked == null) return;
    final imagePath = picked;

    safeEmit(CardScannerLoading(imagePath));

    await handleUseCase(
      ScanCardParams(imagePath: imagePath),
      onFailure: (failure) => safeEmit(
        CardScannerFailure(failure: failure, imagePath: imagePath),
      ),
      onSuccess: (details) => safeEmit(
        details.isEmpty
            ? CardScannerEmpty(imagePath)
            : CardScannerSuccess(imagePath: imagePath, details: details),
      ),
    );
  }

  void reset() => safeEmit(const CardScannerInitial());
}
