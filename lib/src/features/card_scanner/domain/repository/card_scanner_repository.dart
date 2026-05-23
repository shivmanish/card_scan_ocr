import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/card_details.dart';

abstract class CardScannerRepository {
  Future<Either<Failure, CardDetails>> scanCard(String imagePath);
}
