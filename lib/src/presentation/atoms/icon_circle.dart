import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    this.size = 48,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? context.colors.primaryContainer;
    final fg = foreground ?? context.colors.onPrimaryContainer;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, color: fg, size: size * 0.55),
    );
  }
}
