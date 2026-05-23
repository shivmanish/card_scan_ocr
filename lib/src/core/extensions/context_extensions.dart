import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get appTheme => Theme.of(this);
  MediaQueryData get media => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));

  void pop<T extends Object?>([T? result]) =>
      Navigator.of(this).pop<T>(result);
}
