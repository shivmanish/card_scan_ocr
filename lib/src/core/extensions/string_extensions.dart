import '../utils/regex_patterns.dart';

extension StringX on String {
  String get digitsOnly => replaceAll(AppRegex.nonDigit, '');

  String get compact => replaceAll(AppRegex.whitespace, '');

  bool get hasDigit => AppRegex.anyDigit.hasMatch(this);

  /// Splits on line breaks and returns trimmed, non-empty lines.
  List<String> get lines => split(AppRegex.lineSplit)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);

  /// Splits on whitespace and drops empty entries.
  List<String> get words =>
      split(AppRegex.wordSplit).where((w) => w.isNotEmpty).toList();

  /// Replaces common OCR digit misreads (O→0, I/l→1, B→8, S→5, b→6).
  /// Applied only to slices that we already believe should be all digits.
  String get fixOcrDigitMisreads => replaceAll('O', '0')
      .replaceAll('o', '0')
      .replaceAll('I', '1')
      .replaceAll('l', '1')
      .replaceAll('B', '8')
      .replaceAll('S', '5')
      .replaceAll('b', '6');

  /// Case-insensitive whole-word "contains any of these keywords" check.
  ///
  /// Uses `\b` word boundaries so short prepositions in the keyword list
  /// (`TO`, `OF`, `AT`) don't false-match names like `PATEL` (`AT`) or
  /// `TOMAS` (`TO`).
  bool containsAny(Iterable<String> keywords) {
    final upper = toUpperCase();
    for (final kw in keywords) {
      if (RegExp(r'\b' + kw + r'\b').hasMatch(upper)) return true;
    }
    return false;
  }
}
