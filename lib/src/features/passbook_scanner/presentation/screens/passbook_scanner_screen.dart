import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../presentation/atoms/app_loader.dart';
import '../../../../presentation/atoms/app_primary_button.dart';
import '../../../../presentation/atoms/icon_circle.dart';
import '../../../../presentation/molecules/error_banner.dart';
import '../../../../presentation/molecules/image_source_tile.dart';
import '../../../../presentation/molecules/labeled_value.dart';
import '../../../../presentation/organisms/scan_result_card.dart';
import '../../../../presentation/organisms/scanned_image_preview.dart';
import '../../domain/entities/bank_details.dart';
import '../cubit/passbook_scanner_cubit.dart';
import '../cubit/passbook_scanner_state.dart';

class PassbookScannerScreen extends StatelessWidget {
  const PassbookScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassbookScannerCubit>(
      create: (_) => PassbookScannerCubit(
        scanPassbookUseCase: sl(),
        imagePickerService: sl(),
      ),
      child: const _PassbookScannerView(),
    );
  }
}

class _PassbookScannerView extends StatelessWidget {
  const _PassbookScannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Passbook')),
      body: SafeArea(
        child: BlocBuilder<PassbookScannerCubit, PassbookScannerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: switch (state) {
                PassbookScannerInitial() => const _IdleBody(),
                PassbookScannerLoading(:final imagePath) =>
                  _buildLoading(imagePath),
                PassbookScannerSuccess(:final imagePath, :final details) =>
                  _SuccessBody(imagePath: imagePath, details: details),
                PassbookScannerEmpty(:final imagePath) =>
                  _buildEmpty(context, imagePath),
                PassbookScannerFailure(:final failure, :final imagePath) =>
                  _buildFailure(context, failure.message, imagePath),
              },
            );
          },
        ),
      ),
    );
  }
}

// ---------- IDLE — entry experience, kept as class ------------------------

class _IdleBody extends StatelessWidget {
  const _IdleBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PassbookScannerCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(child: IconCircle(icon: Icons.account_balance, size: 72)),
        const SizedBox(height: 16),
        Text(
          'Scan a passbook',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Capture a clear photo of the passbook page to extract the '
          'account holder, account number and IFSC.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        ImageSourceTile(
          icon: Icons.photo_camera_outlined,
          title: 'Use Camera',
          subtitle: 'Take a fresh photo of the page',
          onTap: () => cubit.pickAndScan(ImageSourceType.camera),
        ),
        const SizedBox(height: 12),
        ImageSourceTile(
          icon: Icons.photo_library_outlined,
          title: 'Choose from Gallery',
          subtitle: 'Pick an existing photo',
          onTap: () => cubit.pickAndScan(ImageSourceType.gallery),
        ),
      ],
    );
  }
}

// ---------- SUCCESS — named params + structured result, kept as class -----

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.imagePath, required this.details});
  final String imagePath;
  final BankDetails details;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PassbookScannerCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScannedImagePreview(imagePath: imagePath),
        const SizedBox(height: 16),
        ScanResultCard(
          title: 'Extracted Bank Details',
          rows: [
            LabeledValue(
              label: 'Bank',
              value: details.bankName ?? '—',
            ),
            LabeledValue(
              label: 'Holder',
              value: details.accountHolderName ?? '—',
            ),
            LabeledValue(
              label: 'Account No.',
              value: details.accountNumber ?? '—',
              monospace: true,
            ),
            LabeledValue(
              label: 'IFSC',
              value: details.ifsc ?? '—',
              monospace: true,
            ),
          ],
          primaryActionLabel: 'Scan Again',
          onPrimaryAction: cubit.reset,
        ),
      ],
    );
  }
}

// ---------- inline state views --------------------------------------------

Widget _buildLoading(String imagePath) {
  return Column(
    children: [
      ScannedImagePreview(imagePath: imagePath),
      const SizedBox(height: 28),
      const AppLoader(caption: 'Reading passbook…'),
    ],
  );
}

Widget _buildEmpty(BuildContext context, String imagePath) {
  final cubit = context.read<PassbookScannerCubit>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ScannedImagePreview(imagePath: imagePath),
      const SizedBox(height: 16),
      const ErrorBanner(
        title: 'Couldn\'t find passbook details',
        message:
            'Try a clearer photo of the page with the account number and IFSC visible.',
        icon: Icons.search_off_rounded,
      ),
      const SizedBox(height: 16),
      AppPrimaryButton(
        label: 'Try Again',
        icon: Icons.refresh,
        onPressed: cubit.reset,
        expand: true,
      ),
    ],
  );
}

Widget _buildFailure(BuildContext context, String message, String? imagePath) {
  final cubit = context.read<PassbookScannerCubit>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (imagePath != null) ...[
        ScannedImagePreview(imagePath: imagePath),
        const SizedBox(height: 16),
      ],
      ErrorBanner(title: 'Scan failed', message: message),
      const SizedBox(height: 16),
      AppPrimaryButton(
        label: 'Try Again',
        icon: Icons.refresh,
        onPressed: cubit.reset,
        expand: true,
      ),
    ],
  );
}
