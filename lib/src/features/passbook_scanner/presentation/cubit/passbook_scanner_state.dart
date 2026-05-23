import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_details.dart';

sealed class PassbookScannerState extends Equatable {
  const PassbookScannerState();

  @override
  List<Object?> get props => [];
}

class PassbookScannerInitial extends PassbookScannerState {
  const PassbookScannerInitial();
}

class PassbookScannerLoading extends PassbookScannerState {
  const PassbookScannerLoading(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class PassbookScannerSuccess extends PassbookScannerState {
  const PassbookScannerSuccess({
    required this.imagePath,
    required this.details,
  });
  final String imagePath;
  final BankDetails details;

  @override
  List<Object?> get props => [imagePath, details];
}

class PassbookScannerEmpty extends PassbookScannerState {
  const PassbookScannerEmpty(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class PassbookScannerFailure extends PassbookScannerState {
  const PassbookScannerFailure({required this.failure, this.imagePath});
  final Failure failure;
  final String? imagePath;

  @override
  List<Object?> get props => [failure, imagePath];
}
