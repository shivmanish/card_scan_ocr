import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.warning_amber_rounded,
  });

  final String message;
  final String? title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (title != null) const SizedBox(height: 4),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
