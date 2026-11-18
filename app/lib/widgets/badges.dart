import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.background = AppColors.green2,
    this.foreground = AppColors.green,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: foreground),
      ),
    );
  }
}

/// Out / Low / In stock label for a product.
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.product, this.verbose = false});

  final Product product;
  final bool verbose;

  @override
  Widget build(BuildContext context) {
    if (product.isOut) {
      return AppBadge(
        text: verbose ? 'Out of stock' : 'Out',
        background: AppColors.outBg,
        foreground: AppColors.outFg,
      );
    }
    if (product.isLowStock) {
      return AppBadge(
        text: verbose ? 'Low stock' : 'Low',
        background: AppColors.lowBg,
        foreground: AppColors.lowFg,
      );
    }
    return const AppBadge(text: 'In stock');
  }
}
