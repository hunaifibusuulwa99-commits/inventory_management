import 'package:flutter/material.dart';

import '../theme.dart';
import 'brand_logo.dart';

/// Top bar for screens opened from the More tab (Categories, Suppliers, Profile).
PreferredSizeWidget subPageAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    titleSpacing: 0,
    title: const BrandName(),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: AppColors.line),
    ),
  );
}
