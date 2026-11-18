import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'badges.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(p.emoji, style: const TextStyle(fontSize: 21)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('${p.sku} · ${p.categoryName ?? 'No category'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 2),
                  Text(formatMoney(p.sellingPrice),
                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${p.quantity} units',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                StockBadge(product: p),
                const SizedBox(height: 6),
                const Text('Details →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
