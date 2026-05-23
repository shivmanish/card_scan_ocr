import 'package:equatable/equatable.dart';

class BankDetails extends Equatable {
  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifsc,
    this.bankName,
  });

  final String? accountHolderName;
  final String? accountNumber;
  final String? ifsc;
  final String? bankName;

  bool get isEmpty =>
      accountHolderName == null &&
      accountNumber == null &&
      ifsc == null &&
      bankName == null;

  @override
  List<Object?> get props => [accountHolderName, accountNumber, ifsc, bankName];
}
