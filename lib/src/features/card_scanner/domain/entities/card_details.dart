import 'package:equatable/equatable.dart';

class CardDetails extends Equatable {
  const CardDetails({
    this.cardNumber,
    this.expiry,
    this.holderName,
    this.bankName,
  });

  final String? cardNumber;
  final String? expiry;
  final String? holderName;
  final String? bankName;

  bool get isEmpty =>
      cardNumber == null &&
      expiry == null &&
      holderName == null &&
      bankName == null;

  /// Masks every digit except the last 4 and groups output in 4-char chunks
  /// from the RIGHT so the last-4 stay aligned regardless of card length.
  /// Examples: 16-digit → `XXXX XXXX XXXX 1234`; 15-digit Amex → `XXX XXXX XXXX 1234`.
  String get maskedNumber {
    final n = cardNumber;
    if (n == null || n.length < 4) return '';

    final last4 = n.substring(n.length - 4);
    final maskedPart = 'X' * (n.length - 4);

    final chunks = <String>[];
    for (var end = maskedPart.length; end > 0; end -= 4) {
      chunks.add(maskedPart.substring(end < 4 ? 0 : end - 4, end));
    }
    final prefix = chunks.reversed.join(' ');
    return prefix.isEmpty ? last4 : '$prefix $last4';
  }

  @override
  List<Object?> get props => [cardNumber, expiry, holderName, bankName];
}
