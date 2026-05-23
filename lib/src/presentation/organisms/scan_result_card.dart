import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../atoms/app_primary_button.dart';

class ScanResultCard extends StatelessWidget {
  const ScanResultCard({
    super.key,
    required this.title,
    required this.rows,
    this.headerSlot,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final String title;
  final List<Widget> rows;
  final Widget? headerSlot;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.4,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (headerSlot != null) ...[
              headerSlot!,
              const SizedBox(height: 16),
              const Divider(height: 1),
            ],
            ...rows,
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: primaryActionLabel,
              icon: Icons.refresh,
              onPressed: onPrimaryAction,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}
