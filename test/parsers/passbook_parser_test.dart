import 'package:card_scan_ocr/src/features/passbook_scanner/domain/parsers/passbook_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePassbook', () {
    test('extracts holder, account number, and IFSC from typical passbook', () {
      const raw = '''
STATE BANK OF INDIA
Branch: KORAMANGALA
Name: RAHUL KUMAR SHARMA
A/C No: 31234567890
IFSC: SBIN0001234
Mobile: 9876543210
''';
      final r = parsePassbook(raw);
      expect(r.accountHolderName, 'RAHUL KUMAR SHARMA');
      expect(r.accountNumber, '31234567890');
      expect(r.ifsc, 'SBIN0001234');
    });

    test('picks account number near A/C keyword, not phone number', () {
      const raw = '''
HDFC BANK
Customer: ANITA SINGH
Phone: 9123456780
A/C No 50100123456789
IFSC HDFC0000123
''';
      final r = parsePassbook(raw);
      expect(r.accountNumber, '50100123456789');
      expect(r.ifsc, 'HDFC0000123');
      expect(r.accountHolderName, 'ANITA SINGH');
    });

    test('returns IFSC even when account number is missing', () {
      const raw = '''
Some random text
IFSC: ICIC0001234
''';
      final r = parsePassbook(raw);
      expect(r.ifsc, 'ICIC0001234');
      expect(r.accountNumber, isNull);
    });

    test('handles name on the line below the NAME label', () {
      const raw = '''
HDFC BANK
NAME
PRIYA RAMESH PATEL
A/C 12345678901
''';
      final r = parsePassbook(raw);
      expect(r.accountHolderName, 'PRIYA RAMESH PATEL');
      expect(r.accountNumber, '12345678901');
    });

    test('returns empty BankDetails for empty input', () {
      final r = parsePassbook('');
      expect(r.accountHolderName, isNull);
      expect(r.accountNumber, isNull);
      expect(r.ifsc, isNull);
    });

    test('does not return bank/branch keyword lines as holder name', () {
      const raw = '''
STATE BANK OF INDIA
KORAMANGALA BRANCH
RAHUL SHARMA
A/C 31234567890
''';
      final r = parsePassbook(raw);
      expect(r.accountHolderName, 'RAHUL SHARMA');
    });

    test('disambiguates between multiple long numeric lines via keywords', () {
      const raw = '''
ICICI BANK
Customer ID: 100200300
A/C No: 6677001234567
IFSC: ICIC0001234
Branch Code: 1234567890
''';
      final r = parsePassbook(raw);
      expect(r.accountNumber, '6677001234567');
    });

    test('extracts canonical bank name from a HDFC passbook', () {
      const raw = '''
HDFC BANK
Branch: KORAMANGALA
Name: RAHUL KUMAR SHARMA
A/C No: 50100123456789
IFSC: HDFC0000123
''';
      final r = parsePassbook(raw);
      expect(r.bankName, 'HDFC Bank');
    });

    test('extracts canonical bank from OCR-noisy Union Bank passbook', () {
      const raw = '''
OUA D UNION BANK
of India
Name: PRIYA PATEL
A/C 6677001234567
IFSC UBIN0123456
''';
      final r = parsePassbook(raw);
      expect(r.bankName, 'Union Bank of India');
      expect(r.accountHolderName, 'PRIYA PATEL');
    });

    test('finds account number when label is on the previous line', () {
      const raw = '''
HDFC BANK
A/C Number
50100123456789
IFSC: HDFC0000123
''';
      final r = parsePassbook(raw);
      expect(r.accountNumber, '50100123456789');
    });

    test('penalizes 12-digit number on an Aadhaar line', () {
      const raw = '''
HDFC BANK
Aadhaar: 123456789012
A/C No: 50100123456789
IFSC: HDFC0000123
''';
      final r = parsePassbook(raw);
      expect(r.accountNumber, '50100123456789');
    });

    test('does not pick "WELCOME TO ICICI" as a holder name', () {
      const raw = '''
ICICI BANK
WELCOME TO ICICI
Name: ANITA SINGH
A/C No: 50100123456789
''';
      final r = parsePassbook(raw);
      expect(r.accountHolderName, 'ANITA SINGH');
    });

    test('does not pick PSU slogan as holder name', () {
      const raw = '''
UNION BANK OF INDIA
A Government of India Undertaking
Serving the Nation
A/C No: 50100123456789
IFSC: UBIN0123456
''';
      final r = parsePassbook(raw);
      expect(r.accountHolderName, isNull);
      expect(r.bankName, 'Union Bank of India');
    });
  });
}
