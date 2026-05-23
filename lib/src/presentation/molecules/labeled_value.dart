import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
                letterSpacing: monospace ? 1.2 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
