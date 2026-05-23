import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_details.dart';
import '../../domain/parsers/passbook_parser.dart';
import '../../domain/repository/passbook_scanner_repository.dart';
import '../datasource/passbook_scanner_datasource.dart';

class PassbookScannerRepositoryImpl implements PassbookScannerRepository {
  PassbookScannerRepositoryImpl(this.dataSource);

  final PassbookScannerDataSource dataSource;

  @override
  Future<Either<Failure, BankDetails>> scanPassbook(String imagePath) async {
    try {
      final rawText = await dataSource.getRawText(imagePath);
      return Right(parsePassbook(rawText));
    } catch (e) {
      return Left(OcrFailure('Could not read image: $e'));
    }
  }
}
