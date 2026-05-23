import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/card_details.dart';
import '../repository/card_scanner_repository.dart';

class ScanCardUseCase extends UseCase<CardDetails, ScanCardParams> {
  ScanCardUseCase(this.repository);

  final CardScannerRepository repository;

  @override
  Future<Either<Failure, CardDetails>> call(ScanCardParams params) {
    return repository.scanCard(params.imagePath);
  }
}

class ScanCardParams extends Equatable {
  const ScanCardParams({required this.imagePath});
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}
