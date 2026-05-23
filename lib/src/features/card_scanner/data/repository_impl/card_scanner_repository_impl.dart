import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/card_details.dart';
import '../../domain/parsers/card_parser.dart';
import '../../domain/repository/card_scanner_repository.dart';
import '../datasource/card_scanner_datasource.dart';

class CardScannerRepositoryImpl implements CardScannerRepository {
  CardScannerRepositoryImpl(this.dataSource);

  final CardScannerDataSource dataSource;

  @override
  Future<Either<Failure, CardDetails>> scanCard(String imagePath) async {
    try {
      final rawText = await dataSource.getRawText(imagePath);
      return Right(parseCard(rawText));
    } catch (e) {
      return Left(OcrFailure('Could not read image: $e'));
    }
  }
}
