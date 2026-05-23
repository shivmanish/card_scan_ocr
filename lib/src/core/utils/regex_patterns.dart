class AppRegex {
  AppRegex._();

  // ---- general -----------------------------------------------------------
  static final whitespace = RegExp(r'\s');
  static final lineSplit = RegExp(r'\r?\n');
  static final wordSplit = RegExp(r'\s+');
  static final anyDigit = RegExp(r'\d');
  static final nonDigit = RegExp(r'[^0-9]');

  // ---- card --------------------------------------------------------------
  /// Sliding window of digit-ish characters that could form a 13-19 digit
  /// card number (also accepts O/I/l/B/S that may be OCR misreads).
  static final cardCandidate = RegExp(r'[\dOoIlBSb /\-]{13,}');

  /// Expiry MM/YY, MM-YY, MM YY, MMYY — matched only inside lines that have an
  /// expiry hint keyword.
  static final cardExpiryHinted =
      RegExp(r'\b(0[1-9]|1[0-2])[\/\- ]?(\d{2})\b');

  /// Expiry with an explicit `/` or `-` separator, usable on any line because
  /// a slash/dash cannot occur inside a card number block.
  static final cardExpirySeparated =
      RegExp(r'(?<!\d)(0[1-9]|1[0-2])[\/\-](\d{2})(?!\d)');

  /// A standalone 4-digit MMYY chunk (whole line is just these 4 digits).
  static final cardExpiryStandalone = RegExp(r'^(0[1-9]|1[0-2])(\d{2})$');

  /// One word inside a candidate holder-name line. Allows letters, period,
  /// hyphen, and apostrophe so names like `O'BRIEN`, `JEAN-PIERRE`, and
  /// `D'SOUZA` parse correctly.
  static final nameWord = RegExp(r"^[A-Za-z][A-Za-z\.\-']*$");

  // ---- passbook ----------------------------------------------------------
  /// Indian IFSC: 4 alphabet (bank) + 0 + 6 alphanumeric (branch).
  static final ifsc = RegExp(r'\b[A-Z]{4}0[A-Z0-9]{6}\b');

  /// Account-related keywords used to score a line as likely-account-holder.
  static final passbookAccountKeyword = RegExp(
    r'(a\s*\/\s*c|ac\s*no|account\s*(no|number)?|acct)',
    caseSensitive: false,
  );

  /// Phone-related keywords (penalizes a 10-digit number on such a line).
  static final passbookPhoneKeyword = RegExp(
    r'\b(mobile|phone|tel|mob)\b',
    caseSensitive: false,
  );

  /// Loose 9–22 char digit run (with optional spaces/dashes), filtered later.
  static final passbookNumberRun = RegExp(r'(?:\d[\s\-]?){9,22}');

  /// "Name/Customer/Holder: SOMEONE" inline pattern, capture group 1 = name.
  static final passbookInlineName = RegExp(
    r'(?:name|customer|holder|a\/c\s*holder)\s*[:\-]?\s*([A-Z][A-Z\s\.]{4,})',
    caseSensitive: false,
  );

  /// Lone label "NAME" / "CUSTOMER" / "HOLDER" — name on the next line.
  static final passbookNameLabel = RegExp(
    r'\b(name|customer|holder)\b',
    caseSensitive: false,
  );
}
