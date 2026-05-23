import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bank_details.dart';
import '../repository/passbook_scanner_repository.dart';

class ScanPassbookUseCase extends UseCase<BankDetails, ScanPassbookParams> {
  ScanPassbookUseCase(this.repository);

  final PassbookScannerRepository repository;

  @override
  Future<Either<Failure, BankDetails>> call(ScanPassbookParams params) {
    return repository.scanPassbook(params.imagePath);
  }
}

class ScanPassbookParams extends Equatable {
  const ScanPassbookParams({required this.imagePath});
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}
