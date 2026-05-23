# Card Scan OCR

Flutter app that scans physical credit/debit cards and bank passbooks and extracts structured data via on-device OCR with custom (hand-written) parsing.

## Features

- **Card scanner** — pulls card number, expiry, holder name (when present), and bank name. Number is masked in the UI (`XXXX XXXX XXXX 1234`) and validated with the Luhn checksum.
- **Passbook scanner** — pulls account holder, account number, and IFSC code.
- Image input via camera or gallery.
- Fully offline OCR via Google ML Kit; no backend.

## Steps to run

1. `flutter pub get`
2. Connect an Android device or start an emulator (min API 21).
3. `flutter run` — or `flutter build apk` for a release build.

Run the test suite: `flutter test`

## Libraries used

| Package | Purpose |
|---|---|
| `google_mlkit_text_recognition` | On-device OCR |
| `image_picker` | Camera + gallery access |
| `flutter_bloc` | State management (Cubit) |
| `dartz` | `Either<Failure, T>` for repository results |
| `equatable` | Value equality for entities/states/failures |
| `get_it` | Service locator for DI |

OCR is the only "parsing-adjacent" library. **All field extraction, validation, and Luhn checksum logic is hand-written**, per the assignment constraint.

## Architecture

Clean architecture with feature modules + atomic-design shared widgets:

```
lib/src/
  app.dart                       # MaterialApp root
  core/                          # shared infra; no feature dependencies
    cubit/base_cubit.dart        # safeEmit + handleUseCase helpers
    di/injector.dart             # composition root (get_it)
    error/failures.dart          # sealed Failure hierarchy
    extensions/                  # String, BuildContext extensions
    services/                    # OcrService (ML Kit), ImagePickerService
    theme/app_theme.dart
    usecases/usecase.dart        # UseCase<T, P> base
    utils/regex_patterns.dart    # AppRegex — every RegExp centralized
  features/
    home/                        presentation/
    card_scanner/                data/  domain/  presentation/
    passbook_scanner/            data/  domain/  presentation/
  presentation/                  # shared UI building blocks
    atoms/                       # IconCircle, AppLoader, AppPrimaryButton
    molecules/                   # LabeledValue, ImageSourceTile, ErrorBanner, ScanModeTile
    organisms/                   # ScannedImagePreview, ScanResultCard
```

**Flow per feature:**

```
Cubit ──pick──> ImagePickerService           (camera/gallery)
        ──scan──> UseCase → Repository → DataSource → OcrService (ML Kit)
                                       └── parseCard / parsePassbook (manual)
   ─── Either<Failure, Entity> ── fold ── emit Success | Empty | Failure
```

State management uses **sealed-state Cubits** — `Initial / Loading / Success / Empty / Failure`. Every cubit extends `BaseCubit`, which provides a close-safe `safeEmit` and a `handleUseCase` helper that runs the configured usecase and folds the `Either` into callbacks.

## Core algorithms

Each lives in its feature's domain layer with the exact required signature:

| Function | Location |
|---|---|
| `bool isValidCard(String cardNumber)` | `features/card_scanner/domain/parsers/luhn.dart` |
| `CardDetails parseCard(String rawText)` | `features/card_scanner/domain/parsers/card_parser.dart` |
| `BankDetails parsePassbook(String rawText)` | `features/passbook_scanner/domain/parsers/passbook_parser.dart` |

### Card parser strategy
1. Sweep each line for digit-ish runs (also accepting OCR misreads `O/I/l/B/S/b`).
2. Each candidate is OCR-fixed (`O→0`, `I/l→1`, `B→8`, `S→5`, `b→6`) **only on the digit slice**, never globally — that would corrupt names.
3. Lengths 13–19 are kept and validated with Luhn; first valid candidate wins.
4. Expiry: a line tagged `VALID/THRU/EXP` wins, else a standalone 4-digit `MMYY` line, else a `MM/YY` or `MM-YY` separated form anywhere.
5. Holder: an uppercase line with 2+ alphabetic words that doesn't match brand/keyword noise (`VISA`, `DEBIT`, `BANK`, …).

### Passbook parser strategy
1. **IFSC**: regex `[A-Z]{4}0[A-Z0-9]{6}` over the whole text.
2. **Account number**: collect all 9–18-digit candidates and **score** them — `+5` if the line has `A/C`/`Account`/`Acct`, `+2` if length is 11–16, `−5` if it's a 10-digit number on a `phone`/`mobile` line. Highest score wins.
3. **Holder name**: looks for an inline `Name:`/`Customer:`/`Holder:` label first; then a label-then-next-line pattern; then falls back to the first plausible all-caps 2+-word line that isn't a bank/branch keyword.

### Luhn
Standard right-to-left double-every-second-digit, sum-digits-if-≥10, then check `sum % 10 == 0`.

## Tests

`flutter test` runs the suite. **42 tests** covering:

- **Luhn** (9) — valid Visa/Mastercard/Amex test numbers, dashed/spaced input, invalid checksums, length bounds.
- **Card parser** (16) — `VALID THRU` expiry, dashed `MM-YY`, run-together `MMYY`, OCR misread recovery (`O/I → 0/1`), non-Luhn rejection, brand-noise filtering, missing holder name, erratic spacing, mixed-case name normalization, apostrophe/hyphen names (`O'BRIEN`, `JEAN-PIERRE`), bank-name extraction (`HDFC BANK`, `STATE BANK OF INDIA`, standalone `HDFC`), ATM-card no-false-holder-positive, `BUSINESS ACCOUNT` rejection.
- **Card masking** (4) — 16-digit, 15-digit Amex, 13-digit, and null/short input.
- **Passbook parser** (7) — typical SBI/HDFC layouts, phone-vs-account disambiguation, IFSC-only case, `NAME`-on-next-line, bank-keyword filtering, multi-numeric-line keyword disambiguation.
- **CardScannerCubit** (6) — Success/Empty/Failure emit sequences, picker cancellation no-op, picker exception → `PermissionFailure`, reset clears state.

## Edge cases handled

- **Blurry / partial scans** — Luhn rejects garbage digit runs; parsers emit the `Empty` state when nothing valid is found.
- **OCR misreads** — `O↔0`, `I/l↔1`, `B↔8`, `S↔5`, `b↔6` — fix is applied only to candidate digit slices, never globally.
- **Multiple numbers in passbook text** — context-keyword scoring picks the most likely account number and avoids picking the mobile number.
- **Duplicate / re-entrant scans** — Cubit early-returns while in `Loading`.
- **Missing fields** — every entity field is nullable; UI shows `—` placeholders.
- **Screen popped mid-OCR** — `BaseCubit.safeEmit` skips emits after close; no `Cannot emit after close` crashes.

## Assumptions

- **Indian IFSC format** (4 letters + `0` + 6 alphanumeric). International bank codes would need different patterns.
- **Latin script OCR** — non-Latin scripts not handled.
- **Card lengths 13–19 digits**, account lengths 9–18 digits.
- **English banking labels** (`Name`, `Customer`, `A/C`, `Account`, `IFSC`). Other-language passbooks would need keyword expansion.
- **Card is the dominant subject** of the photo with reasonable lighting/orientation.
- **Android only** — iOS skipped (assignment says optional).

## What was skipped and why

| Skipped | Reason |
|---|---|
| Live camera frame OCR / scan overlay | Still-image via `image_picker` is simpler, more reliable, and OCR accuracy is identical. Live-frame analysis adds the `camera` package, frame throttling, and image rotation handling without changing parser correctness. |
| iOS configuration | Assignment marks iOS optional; staying focused on Android avoided cross-platform setup time. |
| `permission_handler` package | The Android system image picker handles its own permission UX; explicit permission flow would duplicate it. |
| Backend / cloud integration | Explicitly forbidden by the assignment. |
| Dark theme | Material 3 light is sufficient for the assignment scope. |
| Image cropping / perspective correction | Adds significant complexity for marginal accuracy gain on the assignment-grade input. |

## Notes

- The OCR `TextRecognizer` is registered as a **lazy singleton** so the native ML Kit handle isn't re-initialized per scan.
- Min Android API: **21** (ML Kit requirement).
- `image_picker` is called with `imageQuality: 90` to keep file size bounded without losing OCR-relevant detail.
