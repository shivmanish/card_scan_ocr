import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/card_details.dart';

sealed class CardScannerState extends Equatable {
  const CardScannerState();

  @override
  List<Object?> get props => [];
}

class CardScannerInitial extends CardScannerState {
  const CardScannerInitial();
}

class CardScannerLoading extends CardScannerState {
  const CardScannerLoading(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class CardScannerSuccess extends CardScannerState {
  const CardScannerSuccess({required this.imagePath, required this.details});
  final String imagePath;
  final CardDetails details;

  @override
  List<Object?> get props => [imagePath, details];
}

class CardScannerEmpty extends CardScannerState {
  const CardScannerEmpty(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class CardScannerFailure extends CardScannerState {
  const CardScannerFailure({required this.failure, this.imagePath});
  final Failure failure;
  final String? imagePath;

  @override
  List<Object?> get props => [failure, imagePath];
}
