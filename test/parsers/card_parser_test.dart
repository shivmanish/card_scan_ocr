import 'package:card_scan_ocr/src/features/card_scanner/domain/parsers/card_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCard', () {
    test('extracts standard spaced 16-digit Visa with VALID THRU expiry and name', () {
      const raw = '''
VISA
4111 1111 1111 1111
VALID THRU 12/25
JOHN DOE
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
      expect(r.expiry, '12/25');
      expect(r.holderName, 'JOHN DOE');
    });

    test('handles dashed card number and MM-YY expiry', () {
      const raw = '''
MASTERCARD
5500-0000-0000-0004
EXP 09-27
JANE A SMITH
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '5500000000000004');
      expect(r.expiry, '09/27');
      expect(r.holderName, 'JANE A SMITH');
    });

    test('handles run-together MMYY expiry and no spaces in number', () {
      const raw = '''
4111111111111111
0826
JOHN DOE
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
      expect(r.expiry, '08/26');
    });

    test('fixes OCR misreads (O→0, I→1, B→8) before Luhn validation', () {
      // Original 4111111111111111 with O for 0 noise around it, and I for 1 inside.
      const raw = '''
4III IIII IIII IIII
12/25
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
    });

    test('rejects invalid (non-Luhn) numbers and returns null', () {
      const raw = '''
1234 5678 9012 3456
12/25
''';
      final r = parseCard(raw);
      expect(r.cardNumber, isNull);
      expect(r.expiry, '12/25');
    });

    test('returns empty CardDetails for empty input', () {
      final r = parseCard('');
      expect(r.cardNumber, isNull);
      expect(r.expiry, isNull);
      expect(r.holderName, isNull);
    });

    test('does not pick brand keywords as holder name', () {
      const raw = '''
PLATINUM DEBIT CARD
4111 1111 1111 1111
12/25
ALICE J COOPER
''';
      final r = parseCard(raw);
      expect(r.holderName, 'ALICE J COOPER');
    });

    test('returns null holder name when none is present on the card', () {
      const raw = '''
VISA
4111 1111 1111 1111
VALID THRU 12/25
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
      expect(r.expiry, '12/25');
      expect(r.holderName, isNull);
    });

    test('handles erratic spacing within the card number block', () {
      const raw = '''
4 1 1 1   1 1 1 1   1 1 1 1   1 1 1 1
VALID THRU 11/26
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
      expect(r.expiry, '11/26');
    });

    test('uppercases a mixed-case holder name in the output', () {
      const raw = '''
4111 1111 1111 1111
12/25
John Q Doe
''';
      final r = parseCard(raw);
      expect(r.holderName, 'JOHN Q DOE');
    });

    test('accepts names with apostrophes and hyphens (O\'BRIEN, JEAN-PIERRE)', () {
      const raw = '''
4111 1111 1111 1111
12/25
JEAN-PIERRE O'BRIEN
''';
      final r = parseCard(raw);
      expect(r.holderName, "JEAN-PIERRE O'BRIEN");
    });

    test('extracts canonical bank name from a "HDFC BANK" line', () {
      const raw = '''
HDFC BANK
4111 1111 1111 1111
VALID THRU 12/25
JOHN DOE
''';
      final r = parseCard(raw);
      expect(r.bankName, 'HDFC Bank');
      expect(r.holderName, 'JOHN DOE');
    });

    test('extracts canonical State Bank of India from multi-word line', () {
      const raw = '''
STATE BANK OF INDIA
DEBIT CARD
4111 1111 1111 1111
VALID THRU 12/25
RAHUL SHARMA
''';
      final r = parseCard(raw);
      expect(r.bankName, 'State Bank of India');
      expect(r.holderName, 'RAHUL SHARMA');
    });

    test('extracts canonical bank from standalone abbreviation', () {
      const raw = '''
HDFC
4111 1111 1111 1111
12/25
JOHN DOE
''';
      final r = parseCard(raw);
      expect(r.bankName, 'HDFC Bank');
    });

    test('canonicalizes Union Bank from OCR-noisy line (real PSU card)', () {
      // Exact OCR noise pattern from a real Union Bank Rupay card scan.
      const raw = '''
75
Azadi Ka Amrit Mahotsav
OUA D UNION BANK
of India
Andhra Corporation
100 YEARS SERVING THE NATION
6083 3297 3665 7933
VALID THRU 12/28
RK8025214268
DEBIT & PREPAID
RuPay
FOR USE IN INDIA ONLY
A GEVERMENT S LNX TTERTAKNG
''';
      final r = parseCard(raw);
      expect(r.bankName, 'Union Bank of India');
      expect(r.cardNumber, '6083329736657933');
      expect(r.expiry, '12/28');
      expect(
        r.holderName,
        isNull,
        reason: 'PSU boilerplate must not be picked as a holder name',
      );
    });

    test('returns null holder name for an ATM card with back-of-card noise', () {
      const raw = '''
HDFC BANK
DEBIT CARD
4111 1111 1111 1111
VALID THRU 12/25
AUTHORISED SIGNATURE
ELECTRONIC USE ONLY
''';
      final r = parseCard(raw);
      expect(r.cardNumber, '4111111111111111');
      expect(r.expiry, '12/25');
      expect(r.bankName, 'HDFC Bank');
      expect(r.holderName, isNull, reason: 'back-of-card text must not be picked as holder');
    });

    test('does not pick "BUSINESS ACCOUNT" or "PERSONAL ACCOUNT" as holder', () {
      const raw = '''
ICICI BANK
4111 1111 1111 1111
12/25
BUSINESS ACCOUNT
''';
      final r = parseCard(raw);
      expect(r.holderName, isNull);
    });
  });
}
