import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_details.dart';

abstract class PassbookScannerRepository {
  Future<Either<Failure, BankDetails>> scanPassbook(String imagePath);
}
