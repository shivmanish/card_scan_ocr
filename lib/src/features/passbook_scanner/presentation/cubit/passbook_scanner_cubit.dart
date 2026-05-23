import '../../../../core/cubit/base_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../domain/entities/bank_details.dart';
import '../../domain/usecases/scan_passbook_usecase.dart';
import 'passbook_scanner_state.dart';

class PassbookScannerCubit
    extends BaseCubit<PassbookScannerState, BankDetails, ScanPassbookParams> {
  PassbookScannerCubit({
    required ScanPassbookUseCase scanPassbookUseCase,
    required this.imagePickerService,
  }) : super(
          initialState: const PassbookScannerInitial(),
          useCase: scanPassbookUseCase,
        );

  final ImagePickerService imagePickerService;

  Future<void> pickAndScan(ImageSourceType source) async {
    if (state is PassbookScannerLoading) return;

    final String? picked;
    try {
      picked = await imagePickerService.pickImage(source);
    } catch (_) {
      safeEmit(
        const PassbookScannerFailure(
          failure: PermissionFailure(
            'Could not access the image. Check app permissions.',
          ),
        ),
      );
      return;
    }
    if (picked == null) return;
    final imagePath = picked;

    safeEmit(PassbookScannerLoading(imagePath));

    await handleUseCase(
      ScanPassbookParams(imagePath: imagePath),
      onFailure: (failure) => safeEmit(
        PassbookScannerFailure(failure: failure, imagePath: imagePath),
      ),
      onSuccess: (details) => safeEmit(
        details.isEmpty
            ? PassbookScannerEmpty(imagePath)
            : PassbookScannerSuccess(imagePath: imagePath, details: details),
      ),
    );
  }

  void reset() => safeEmit(const PassbookScannerInitial());
}
