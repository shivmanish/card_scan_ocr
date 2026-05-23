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
import '../../domain/entities/card_details.dart';
import '../cubit/card_scanner_cubit.dart';
import '../cubit/card_scanner_state.dart';
import '../widgets/masked_card_number_view.dart';

class CardScannerScreen extends StatelessWidget {
  const CardScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardScannerCubit>(
      create: (_) => CardScannerCubit(
        scanCardUseCase: sl(),
        imagePickerService: sl(),
      ),
      child: const _CardScannerView(),
    );
  }
}

class _CardScannerView extends StatelessWidget {
  const _CardScannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Card')),
      body: SafeArea(
        child: BlocBuilder<CardScannerCubit, CardScannerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: switch (state) {
                CardScannerInitial() => const _IdleBody(),
                CardScannerLoading(:final imagePath) =>
                  _buildLoading(imagePath),
                CardScannerSuccess(:final imagePath, :final details) =>
                  _SuccessBody(imagePath: imagePath, details: details),
                CardScannerEmpty(:final imagePath) =>
                  _buildEmpty(context, imagePath),
                CardScannerFailure(:final failure, :final imagePath) =>
                  _buildFailure(context, failure.message, imagePath),
              },
            );
          },
        ),
      ),
    );
  }
}

// ---------- IDLE — kept as class: many children, "entry experience" identity

class _IdleBody extends StatelessWidget {
  const _IdleBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardScannerCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(child: IconCircle(icon: Icons.credit_card, size: 72)),
        const SizedBox(height: 16),
        Text(
          'Scan a card',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Capture a clear photo of your card to extract the number, '
          'expiry and holder name.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        ImageSourceTile(
          icon: Icons.photo_camera_outlined,
          title: 'Use Camera',
          subtitle: 'Take a fresh photo of the card',
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

// ---------- SUCCESS — kept as class: named params + structured result block

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.imagePath, required this.details});
  final String imagePath;
  final CardDetails details;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardScannerCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScannedImagePreview(imagePath: imagePath),
        const SizedBox(height: 16),
        ScanResultCard(
          title: 'Extracted Card Details',
          headerSlot: details.cardNumber != null
              ? MaskedCardNumberView(masked: details.maskedNumber)
              : null,
          rows: [
            LabeledValue(label: 'Bank', value: details.bankName ?? '—'),
            LabeledValue(label: 'Expiry', value: details.expiry ?? '—'),
            LabeledValue(label: 'Holder', value: details.holderName ?? '—'),
          ],
          primaryActionLabel: 'Scan Again',
          onPrimaryAction: cubit.reset,
        ),
      ],
    );
  }
}

// ---------- inline state views ---------------------------------------------

Widget _buildLoading(String imagePath) {
  return Column(
    children: [
      ScannedImagePreview(imagePath: imagePath),
      const SizedBox(height: 28),
      const AppLoader(caption: 'Reading card details…'),
    ],
  );
}

Widget _buildEmpty(BuildContext context, String imagePath) {
  final cubit = context.read<CardScannerCubit>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ScannedImagePreview(imagePath: imagePath),
      const SizedBox(height: 16),
      const ErrorBanner(
        title: 'Couldn\'t find card details',
        message:
            'Try a clearer photo with even lighting and the full card in frame.',
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
  final cubit = context.read<CardScannerCubit>();
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
