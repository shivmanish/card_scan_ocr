import 'package:card_scan_ocr/src/features/card_scanner/domain/parsers/luhn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidCard (Luhn)', () {
    test('returns true for known-valid 16-digit Visa test number', () {
      expect(isValidCard('4111111111111111'), isTrue);
    });

    test('returns true for known-valid Mastercard test number', () {
      expect(isValidCard('5500000000000004'), isTrue);
    });

    test('returns true for known-valid 15-digit Amex test number', () {
      expect(isValidCard('378282246310005'), isTrue);
    });

    test('returns true when number has spaces and dashes', () {
      expect(isValidCard('4111-1111 1111-1111'), isTrue);
    });

    test('returns false for invalid checksum', () {
      expect(isValidCard('4111111111111112'), isFalse);
    });

    test('returns false for too-short input', () {
      expect(isValidCard('411111'), isFalse);
    });

    test('returns false for too-long input (>19 digits)', () {
      expect(isValidCard('41111111111111111111'), isFalse);
    });

    test('returns false when input has no digits', () {
      expect(isValidCard('hello world'), isFalse);
    });

    test('returns false for empty string', () {
      expect(isValidCard(''), isFalse);
    });
  });
}
