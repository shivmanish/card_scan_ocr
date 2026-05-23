import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../presentation/molecules/scan_mode_tile.dart';
import '../../../card_scanner/presentation/screens/card_scanner_screen.dart';
import '../../../passbook_scanner/presentation/screens/passbook_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Scan OCR')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 24),
              ScanModeTile(
                icon: Icons.credit_card,
                title: 'Credit / Debit Card',
                subtitle: 'Card number, expiry & holder name',
                onTap: () => context.push(const CardScannerScreen()),
              ),
              const SizedBox(height: 12),
              ScanModeTile(
                icon: Icons.account_balance,
                title: 'Bank Passbook',
                subtitle: 'Account holder, number & IFSC code',
                onTap: () => context.push(const PassbookScannerScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan & extract',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Capture details from cards and bank passbooks instantly.',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
