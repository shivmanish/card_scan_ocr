import 'package:bloc_test/bloc_test.dart';
import 'package:card_scan_ocr/src/core/error/failures.dart';
import 'package:card_scan_ocr/src/core/services/image_picker_service.dart';
import 'package:card_scan_ocr/src/features/card_scanner/domain/entities/card_details.dart';
import 'package:card_scan_ocr/src/features/card_scanner/domain/usecases/scan_card_usecase.dart';
import 'package:card_scan_ocr/src/features/card_scanner/presentation/cubit/card_scanner_cubit.dart';
import 'package:card_scan_ocr/src/features/card_scanner/presentation/cubit/card_scanner_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockScanCardUseCase extends Mock implements ScanCardUseCase {}

class _MockImagePickerService extends Mock implements ImagePickerService {}

const _validDetails = CardDetails(
  cardNumber: '4111111111111111',
  expiry: '12/25',
  holderName: 'JOHN DOE',
);

void main() {
  late _MockScanCardUseCase useCase;
  late _MockImagePickerService picker;

  setUpAll(() {
    registerFallbackValue(const ScanCardParams(imagePath: 'fallback'));
    registerFallbackValue(ImageSourceType.camera);
  });

  setUp(() {
    useCase = _MockScanCardUseCase();
    picker = _MockImagePickerService();
  });

  CardScannerCubit build() => CardScannerCubit(
        scanCardUseCase: useCase,
        imagePickerService: picker,
      );

  group('CardScannerCubit.pickAndScan', () {
    blocTest<CardScannerCubit, CardScannerState>(
      'emits [Loading, Success] when pick succeeds and parser returns details',
      setUp: () {
        when(() => picker.pickImage(any()))
            .thenAnswer((_) async => '/tmp/card.jpg');
        when(() => useCase.call(any()))
            .thenAnswer((_) async => const Right(_validDetails));
      },
      build: build,
      act: (c) => c.pickAndScan(ImageSourceType.camera),
      expect: () => [
        const CardScannerLoading('/tmp/card.jpg'),
        const CardScannerSuccess(
          imagePath: '/tmp/card.jpg',
          details: _validDetails,
        ),
      ],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'emits [Loading, Empty] when parser returns an empty CardDetails',
      setUp: () {
        when(() => picker.pickImage(any()))
            .thenAnswer((_) async => '/tmp/blank.jpg');
        when(() => useCase.call(any()))
            .thenAnswer((_) async => const Right(CardDetails()));
      },
      build: build,
      act: (c) => c.pickAndScan(ImageSourceType.gallery),
      expect: () => [
        const CardScannerLoading('/tmp/blank.jpg'),
        const CardScannerEmpty('/tmp/blank.jpg'),
      ],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'emits [Loading, Failure] when usecase returns Left(Failure)',
      setUp: () {
        when(() => picker.pickImage(any()))
            .thenAnswer((_) async => '/tmp/bad.jpg');
        when(() => useCase.call(any())).thenAnswer(
          (_) async => const Left(OcrFailure('boom')),
        );
      },
      build: build,
      act: (c) => c.pickAndScan(ImageSourceType.camera),
      expect: () => [
        const CardScannerLoading('/tmp/bad.jpg'),
        const CardScannerFailure(
          failure: OcrFailure('boom'),
          imagePath: '/tmp/bad.jpg',
        ),
      ],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'emits nothing when user cancels the picker (null path)',
      setUp: () {
        when(() => picker.pickImage(any())).thenAnswer((_) async => null);
      },
      build: build,
      act: (c) => c.pickAndScan(ImageSourceType.camera),
      expect: () => const <CardScannerState>[],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'emits Failure when the picker itself throws (permission denied)',
      setUp: () {
        when(() => picker.pickImage(any())).thenThrow(Exception('denied'));
      },
      build: build,
      act: (c) => c.pickAndScan(ImageSourceType.camera),
      expect: () => [isA<CardScannerFailure>()],
    );
  });

  group('CardScannerCubit.reset', () {
    blocTest<CardScannerCubit, CardScannerState>(
      'emits Initial regardless of current state',
      build: build,
      seed: () => const CardScannerEmpty('/tmp/x.jpg'),
      act: (c) => c.reset(),
      expect: () => [const CardScannerInitial()],
    );
  });
}
