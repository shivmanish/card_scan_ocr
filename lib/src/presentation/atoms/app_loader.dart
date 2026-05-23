import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.caption});

  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (caption != null) ...[
          const SizedBox(height: 12),
          Text(
            caption!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
