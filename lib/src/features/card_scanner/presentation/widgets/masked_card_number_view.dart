import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

class MaskedCardNumberView extends StatelessWidget {
  const MaskedCardNumberView({super.key, required this.masked});

  final String masked;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        masked,
        style: context.textTheme.headlineSmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}
