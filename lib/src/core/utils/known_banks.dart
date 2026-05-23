/// Canonical Indian bank names used by both card and passbook parsers.
///
/// Patterns are tried in order; the FIRST hit wins. Always list more-specific
/// patterns (e.g. `KOTAK MAHINDRA`) before their shorter shape (`KOTAK`).
const _canonicalIndianBanks = <(String, String)>[
  // multi-word patterns first
  ('UNION BANK', 'Union Bank of India'),
  ('STATE BANK', 'State Bank of India'),
  ('HDFC BANK', 'HDFC Bank'),
  ('ICICI BANK', 'ICICI Bank'),
  ('AXIS BANK', 'Axis Bank'),
  ('KOTAK MAHINDRA', 'Kotak Mahindra Bank'),
  ('PUNJAB NATIONAL', 'Punjab National Bank'),
  ('BANK OF BARODA', 'Bank of Baroda'),
  ('BANK OF INDIA', 'Bank of India'),
  ('CENTRAL BANK', 'Central Bank of India'),
  ('CANARA BANK', 'Canara Bank'),
  ('FEDERAL BANK', 'Federal Bank'),
  ('YES BANK', 'Yes Bank'),
  ('IDFC FIRST', 'IDFC First Bank'),
  ('INDUSIND BANK', 'IndusInd Bank'),
  ('BANDHAN BANK', 'Bandhan Bank'),
  ('IDBI BANK', 'IDBI Bank'),
  ('STANDARD CHARTERED', 'Standard Chartered Bank'),
  ('AMERICAN EXPRESS', 'American Express'),
  // single-word fallbacks
  ('HDFC', 'HDFC Bank'),
  ('ICICI', 'ICICI Bank'),
  ('AXIS', 'Axis Bank'),
  ('KOTAK', 'Kotak Mahindra Bank'),
  ('CANARA', 'Canara Bank'),
  ('INDUSIND', 'IndusInd Bank'),
  ('BANDHAN', 'Bandhan Bank'),
  ('IDFC', 'IDFC First Bank'),
  ('IDBI', 'IDBI Bank'),
  ('CITIBANK', 'Citibank'),
  ('CITI', 'Citibank'),
  ('HSBC', 'HSBC Bank'),
  ('AMEX', 'American Express'),
  ('SBI', 'State Bank of India'),
  ('PNB', 'Punjab National Bank'),
  ('RBL', 'RBL Bank'),
  ('BOI', 'Bank of India'),
  ('BOB', 'Bank of Baroda'),
];

/// Returns the canonical bank name if [line] (case-insensitive) contains a
/// known bank pattern as a whole word; otherwise null.
///
/// Handles OCR noise like `OUA D UNION BANK` → `Union Bank of India`.
String? matchCanonicalBank(String line) {
  final upper = line.toUpperCase();
  for (final (pattern, canonical) in _canonicalIndianBanks) {
    if (RegExp(r'\b' + pattern + r'\b').hasMatch(upper)) {
      return canonical;
    }
  }
  return null;
}
