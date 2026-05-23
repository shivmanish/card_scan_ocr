import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/utils/known_banks.dart';
import '../../../../core/utils/regex_patterns.dart';
import '../entities/bank_details.dart';

/// Lines whose keywords (whole-word match via [String.containsAny]) mean the
/// line is NOT a plausible holder name. Covers bank names, PSU slogans,
/// passbook headers, statement labels, greetings, etc.
const _nonNameKeywords = {
  // Passbook / statement labels
  'BANK', 'BRANCH', 'IFSC', 'ACCOUNT', 'PASSBOOK', 'CUSTOMER', 'ADDRESS',
  'PHONE', 'MOBILE', 'EMAIL', 'CITY', 'STATE', 'PIN', 'CODE',
  'LIMITED', 'LTD', 'STATEMENT', 'BALANCE', 'TRANSACTION', 'OPENING',
  'CLOSING', 'TYPE', 'NOMINEE', 'JOINT', 'OPERATIONS', 'SCHEME',
  // Greetings
  'DEAR', 'WELCOME', 'GREETINGS', 'HELLO',
  // English prepositions/conjunctions (often appear in slogans)
  'TO', 'OF', 'FOR', 'AT', 'AND', 'OR', 'FROM', 'WITH',
  // Indian PSU slogans
  'GOVERNMENT', 'GOVERMENT', 'UNDERTAKING', 'INDIA', 'INDIAN',
  'AZADI', 'AMRIT', 'MAHOTSAV', 'SERVING', 'NATION', 'YEARS',
  'ANDHRA', 'CORPORATION', 'NATIONAL',
  // Card networks
  'RUPAY', 'VISA', 'MASTERCARD',
  // Bank brand words (so "WELCOME TO ICICI" is filtered)
  'HDFC', 'ICICI', 'AXIS', 'SBI', 'KOTAK', 'PNB', 'IDFC', 'RBL',
  'INDUSIND', 'BANDHAN', 'FEDERAL', 'CANARA', 'IDBI', 'CITI', 'HSBC',
  'UNION', 'PUNJAB', 'BARODA',
};

BankDetails parsePassbook(String rawText) {
  if (rawText.trim().isEmpty) return const BankDetails();

  final lines = rawText.lines;

  return BankDetails(
    accountHolderName: _extractHolderName(lines),
    accountNumber: _extractAccountNumber(lines),
    ifsc: _extractIfsc(rawText),
    bankName: _extractBankName(lines),
  );
}

String? _extractBankName(List<String> lines) {
  for (final line in lines) {
    if (line.hasDigit) continue;
    final canonical = matchCanonicalBank(line);
    if (canonical != null) return canonical;
  }
  // Fallback: any line containing whole-word "BANK".
  final bankRe = RegExp(r'\bBANK\b');
  for (final line in lines) {
    if (line.hasDigit) continue;
    final upper = line.toUpperCase().trim();
    if (bankRe.hasMatch(upper)) {
      final cleaned = upper
          .replaceAll(RegExp(r'[^A-Z\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (cleaned.isNotEmpty && cleaned != 'BANK') return cleaned;
    }
  }
  return null;
}

String? _extractIfsc(String rawText) {
  final upper = rawText.toUpperCase();
  return AppRegex.ifsc.firstMatch(upper)?.group(0);
}

String? _extractAccountNumber(List<String> lines) {
  final aadhaarKeywordRe = RegExp(
    r'\b(aadhaar|aadhar|uid|uidai)\b',
    caseSensitive: false,
  );

  String? best;
  var bestScore = -1000;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final prevLine = i > 0 ? lines[i - 1] : '';

    // Common passbook layout: "A/c No." on the label line and the value on
    // the next line. Treat the keyword as present if EITHER current or the
    // immediately-previous line has it.
    final hasAccKw = AppRegex.passbookAccountKeyword.hasMatch(line) ||
        AppRegex.passbookAccountKeyword.hasMatch(prevLine);
    final hasPhoneKw = AppRegex.passbookPhoneKeyword.hasMatch(line);
    final hasAadhaarKw = aadhaarKeywordRe.hasMatch(line) ||
        aadhaarKeywordRe.hasMatch(prevLine);

    for (final m in AppRegex.passbookNumberRun.allMatches(line)) {
      final digits = m.group(0)!.digitsOnly;
      if (digits.length < 9 || digits.length > 18) continue;

      // Weights tuned so an explicit account keyword (+5) decisively beats
      // length signal (+2) and Aadhaar/phone candidates (-5).
      var score = 0;
      if (hasAccKw) score += 5; // account-context keyword on this/prev line
      if (digits.length >= 11 && digits.length <= 16) score += 2; // typical Indian acc no length
      if (hasPhoneKw && digits.length == 10) score -= 5; // 10-digit on a phone line
      if (digits.length == 10 && !hasAccKw) score -= 1; // plain 10-digit, no account context
      if (hasAadhaarKw && digits.length == 12) score -= 5; // 12-digit on an Aadhaar line

      if (score > bestScore) {
        bestScore = score;
        best = digits;
      }
    }
  }
  return best;
}

String? _extractHolderName(List<String> lines) {
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    final inline = AppRegex.passbookInlineName.firstMatch(line);
    if (inline != null) {
      final candidate = inline.group(1)!.trim();
      if (_isPlausibleName(candidate)) return candidate.toUpperCase();
    }

    if (AppRegex.passbookNameLabel.hasMatch(line) && i + 1 < lines.length) {
      final next = lines[i + 1].trim();
      if (_isPlausibleName(next) && !next.containsAny(_nonNameKeywords)) {
        return next.toUpperCase();
      }
    }
  }

  for (final line in lines) {
    if (!_isPlausibleName(line)) continue;
    if (line.containsAny(_nonNameKeywords)) continue;
    return line.toUpperCase();
  }
  return null;
}

bool _isPlausibleName(String s) {
  if (s.isEmpty || s.hasDigit) return false;
  final words = s.words;
  // Real Indian holder names are 2–5 words. 6+ words is almost always OCR
  // noise (e.g. a slogan like "A Government of India Undertaking").
  if (words.length < 2 || words.length > 5) return false;
  for (final w in words) {
    if (!AppRegex.nameWord.hasMatch(w)) return false;
  }
  return true;
}
