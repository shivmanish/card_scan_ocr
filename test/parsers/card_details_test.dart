import 'package:card_scan_ocr/src/features/card_scanner/domain/entities/card_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardDetails.maskedNumber', () {
    test('masks a 16-digit number as 4-4-4-4', () {
      const d = CardDetails(cardNumber: '4111111111111111');
      expect(d.maskedNumber, 'XXXX XXXX XXXX 1111');
    });

    test('masks a 15-digit Amex as 3-4-4-4 (length preserved)', () {
      const d = CardDetails(cardNumber: '378282246310005');
      expect(d.maskedNumber, 'XXX XXXX XXXX 0005');
    });

    test('masks a 13-digit number as 1-4-4-4 (length preserved)', () {
      const d = CardDetails(cardNumber: '4012888888881881');
      expect(d.maskedNumber, 'XXXX XXXX XXXX 1881');
    });

    test('returns empty string when number is null or too short', () {
      expect(const CardDetails().maskedNumber, '');
      expect(const CardDetails(cardNumber: '12').maskedNumber, '');
    });
  });
}
