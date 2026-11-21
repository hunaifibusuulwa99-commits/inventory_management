import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/badges.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_field.dart';

/// Shows a product's details. Returns what the user chose: 'edit', 'stock' or 'deleted'.
Future<String?> showProductDetailsSheet(BuildContext context, Product product) {
  return showAppSheet<String>(
    context,
    title: 'Product details',
    builder: (_) => _ProductDetails(product: product),
  );
}

class _ProductDetails extends StatefulWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  State<_ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<_ProductDetails> {
  bool _deleting = false;
  String? _error;

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Delete product?',
      message: 'This will also delete its stock history. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await ProductService().delete(widget.product.id);
      if (!mounted) return;
      Navigator.of(context).pop('deleted');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.message;
      });
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(p.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(p.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(p.sku, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 12),
              Text(formatMoney(p.sellingPrice),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              StockBadge(product: p, verbose: true),
            ],
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          child: Column(
            children: withDividers([
              _row('Category', p.categoryName ?? '—'),
              _row('Supplier', p.supplierName ?? '—'),
              _row('Cost price', formatMoney(p.costPrice)),
              _row('Available quantity', '${p.quantity} units'),
              _row('Low-stock alert at', '${p.reorderLevel} units'),
              _row('Stock value', formatMoney(p.stockValue)),
              if (p.description != null && p.description!.isNotEmpty)
                _row('Description', p.description!),
            ]),
          ),
        ),
        FormError(_error),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _deleting ? null : () => Navigator.of(context).pop('edit'),
                child: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _deleting ? null : () => Navigator.of(context).pop('stock'),
                child: const Text('Adjust stock'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _deleting ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          child: _deleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.red),
                )
              : const Text('Delete product', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
