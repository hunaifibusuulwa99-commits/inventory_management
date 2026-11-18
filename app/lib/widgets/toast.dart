import 'package:flutter/material.dart';

import '../services/app_keys.dart';
import '../theme.dart';

/// Short message at the bottom of the screen (green = success, red = error).
void showToast(String message, {bool error = false}) {
  final messenger = messengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.red : AppColors.toast,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(milliseconds: 2800),
      ),
    );
}
