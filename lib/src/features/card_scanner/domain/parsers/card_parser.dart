import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/utils/known_banks.dart';
import '../../../../core/utils/regex_patterns.dart';
import '../entities/card_details.dart';
import 'luhn.dart';

/// Words that, if present anywhere on a line, mean that line is NOT a holder
/// name. Covers card brands, tiers, validity labels, back-of-card boilerplate,
/// and Indian PSU-card slogan text ("A Government of India Undertaking",
/// "Azadi Ka Amrit Mahotsav", "Serving the Nation", etc.) so we don't pick
/// noise as the holder.
const _brandAndNoiseKeywords = {
  // Brand / network
  'VISA', 'MASTERCARD', 'MASTER', 'RUPAY', 'MAESTRO', 'AMERICAN', 'EXPRESS',
  'AMEX', 'DINERS', 'DISCOVER', 'JCB',
  // Card type / tier
  'DEBIT', 'CREDIT', 'CARD', 'PREPAID', 'CONTACTLESS', 'CHIP', 'ATM',
  'PLATINUM', 'GOLD', 'SILVER', 'CLASSIC', 'WORLD', 'TITANIUM',
  'INFINITE', 'PRIVATE', 'BUSINESS', 'PERSONAL', 'PREMIUM', 'REGULAR',
  // Validity / dates
  'VALID', 'THRU', 'EXP', 'EXPIRES', 'EXPIRY', 'FROM', 'MEMBER', 'SINCE',
  'MONTH', 'YEAR', 'YEARS',
  // Bank / institutional
  'BANK', 'BANCO', 'BANCA', 'FINANCIAL', 'CAPITAL', 'TRUST', 'NATIONAL',
  // Back-of-card boilerplate
  'AUTHORISED', 'AUTHORIZED', 'SIGNATURE', 'PIN', 'REQUIRED', 'MANDATORY',
  'ELECTRONIC', 'ONLY', 'USE', 'USAGE', 'ABOVE', 'BELOW',
  'ISSUED', 'PROPERTY', 'RETURN', 'CALL', 'CUSTOMER', 'SERVICE', 'HELP',
  'TERMS', 'CONDITIONS', 'APPLY',
  // Indian PSU card slogans / boilerplate
  'GOVERNMENT', 'GOVERMENT', 'UNDERTAKING', 'INDIA', 'INDIAN',
  'AZADI', 'AMRIT', 'MAHOTSAV', 'SERVING', 'NATION',
  'ANDHRA', 'CORPORATION', 'DESI',
  // Generic UI / label noise
  'TAP', 'PAY', 'BANKING', 'CARDHOLDER', 'HOLDER', 'NAME',
  'ACCOUNT', 'NUMBER', 'CODE', 'BRANCH', 'IFSC',
};

const _expiryHints = ['VALID', 'THRU', 'EXP', 'MONTH/YEAR'];

final _bankWord = RegExp(r'\bBANK\b');

CardDetails parseCard(String rawText) {
  if (rawText.trim().isEmpty) return const CardDetails();

  final lines = rawText.lines;

  return CardDetails(
    cardNumber: _extractCardNumber(lines),
    expiry: _extractExpiry(lines),
    bankName: _extractBankName(lines),
    holderName: _extractHolderName(lines),
  );
}

String? _extractCardNumber(List<String> lines) {
  final candidates = <String>[];

  for (final line in lines) {
    for (final m in AppRegex.cardCandidate.allMatches(line)) {
      final digits = m.group(0)!.fixOcrDigitMisreads.digitsOnly;
      if (digits.length >= 13 && digits.length <= 19) {
        candidates.add(digits);
      }
    }
  }

  candidates.sort((a, b) => b.length.compareTo(a.length));
  for (final c in candidates) {
    if (isValidCard(c)) return c;
  }
  return null;
}

String? _extractExpiry(List<String> lines) {
  String? fallback;

  for (final line in lines) {
    if (line.containsAny(_expiryHints)) {
      final m = AppRegex.cardExpiryHinted.firstMatch(line);
      if (m != null) return '${m.group(1)}/${m.group(2)}';
    }

    final standalone = AppRegex.cardExpiryStandalone.firstMatch(line.compact);
    if (standalone != null) {
      fallback ??= '${standalone.group(1)}/${standalone.group(2)}';
      continue;
    }

    final sepMatch = AppRegex.cardExpirySeparated.firstMatch(line);
    if (sepMatch != null) {
      fallback ??= '${sepMatch.group(1)}/${sepMatch.group(2)}';
    }
  }
  return fallback;
}

/// Returns a canonical bank name when a known pattern is matched anywhere in
/// the OCR text (handles OCR noise like `OUA D UNION BANK` → `Union Bank of India`).
/// Falls back to a cleaned line containing `BANK` for unknown banks.
String? _extractBankName(List<String> lines) {
  // Pass 1: canonical match anywhere.
  for (final line in lines) {
    if (line.hasDigit) continue;
    final canonical = matchCanonicalBank(line);
    if (canonical != null) return canonical;
  }

  // Pass 2: any line with the whole word "BANK" — cleaned fallback.
  for (final line in lines) {
    if (line.hasDigit) continue;
    final upper = line.toUpperCase().trim();
    if (_bankWord.hasMatch(upper)) {
      final cleaned = upper
          .replaceAll(RegExp(r'[^A-Z\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (cleaned.isNotEmpty && cleaned != 'BANK') return cleaned;
    }
  }
  return null;
}

String? _extractHolderName(List<String> lines) {
  String? best;

  for (final line in lines) {
    if (line.hasDigit) continue;
    final words = line.words;
    // Real holder names are 2-4 words. 5+ words is almost always OCR noise
    // (e.g. "A GEVERMENT S LNX TTERTAKNG" is 5 words of pure garble).
    if (words.length < 2 || words.length > 4) continue;

    var allValid = true;
    var hasLongWord = false;
    var totalLetters = 0;
    for (final w in words) {
      if (!AppRegex.nameWord.hasMatch(w)) {
        allValid = false;
        break;
      }
      if (w.length >= 3) hasLongWord = true;
      totalLetters += w.length;
    }
    if (!allValid || !hasLongWord || totalLetters < 6) continue;
    if (line.containsAny(_brandAndNoiseKeywords)) continue;

    final upper = line.toUpperCase();
    if (best == null || upper.length > best.length) best = upper;
  }
  return best;
}
