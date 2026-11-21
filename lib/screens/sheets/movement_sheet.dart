import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/product.dart';
import '../../models/stock_movement.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../services/stock_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/data_loader.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/state_views.dart';
import '../../widgets/toast.dart';

/// Opens the stock form (in / out / adjust). Returns true if a movement was saved.
Future<bool> showMovementSheet(
  BuildContext context, {
  String type = 'in',
  Product? product,
}) async {
  final result = await showAppSheet<StockMovement>(
    context,
    title: 'Update stock',
    builder: (_) => _MovementLoader(initialType: type, product: product),
  );
  if (result == null) return false;
  switch (result.type) {
    case 'in':
      showToast('Stock added successfully');
      break;
    case 'out':
      showToast('Stock removed successfully');
      break;
    default:
      showToast('Stock count updated');
  }
  return true;
}

class _MovementLoader extends StatelessWidget {
  const _MovementLoader({required this.initialType, this.product});

  final String initialType;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return DataLoader<List<Product>>(
      load: () => ProductService().list(),
      builder: (context, products, _) {
        if (products.isEmpty) {
          return const EmptyView(
            emoji: '📦',
            title: 'No products yet',
            message: 'Add a product first, then you can record stock for it.',
          );
        }
        return _MovementForm(products: products, initialType: initialType, initialProduct: product);
      },
    );
  }
}

class _MovementForm extends StatefulWidget {
  const _MovementForm({required this.products, required this.initialType, this.initialProduct});

  final List<Product> products;
  final String initialType;
  final Product? initialProduct;

  @override
  State<_MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<_MovementForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  late String _type = widget.initialType;
  late int _productId;
  bool _saving = false;
  String? _error;

  Product get _selected => widget.products.firstWhere((p) => p.id == _productId);

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProduct;
    final exists = initial != null && widget.products.any((p) => p.id == initial.id);
    _productId = exists ? initial.id : widget.products.first.id;
    _quantity.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _enteredQuantity => int.tryParse(_quantity.text.trim());

  /// What the stock will be after saving, or null if the input is not valid yet.
  int? get _preview {
    final q = _enteredQuantity;
    if (q == null) return null;
    final current = _selected.quantity;
    switch (_type) {
      case 'in':
        return q >= 1 ? current + q : null;
      case 'out':
        return (q >= 1 && q <= current) ? current - q : null;
      default:
        return q >= 0 ? q : null;
    }
  }

  String? _validateQuantity(String? v) {
    final q = int.tryParse((v ?? '').trim());
    if (q == null) return 'Enter a whole number';
    if (_type != 'adjust' && q < 1) return 'Quantity must be at least 1';
    if (q < 0) return 'Quantity cannot be negative';
    if (_type == 'out' && q > _selected.quantity) return 'Not enough stock available';
    return null;
  }

  String get _quantityLabel => _type == 'adjust' ? 'Counted quantity' : 'Quantity';

  String get _noteHint {
    switch (_type) {
      case 'in':
        return 'Supplier delivery';
      case 'out':
        return 'Customer sale';
      default:
        return 'Stock count';
    }
  }

  String get _confirmLabel {
    switch (_type) {
      case 'in':
        return 'Confirm stock in';
      case 'out':
        return 'Confirm stock out';
      default:
        return 'Confirm adjustment';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final movement = await StockService().create(
        productId: _productId,
        type: _type,
        quantity: _enteredQuantity!,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(movement);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'in', label: Text('Stock in')),
              ButtonSegment(value: 'out', label: Text('Stock out')),
              ButtonSegment(value: 'adjust', label: Text('Adjust')),
            ],
            selected: {_type},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedBackgroundColor: AppColors.green2,
              selectedForegroundColor: AppColors.green,
              foregroundColor: AppColors.muted,
            ),
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              _error = null;
            }),
          ),
          const SizedBox(height: 14),
          LabeledDropdown<int>(
            label: 'Select product',
            value: _productId,
            items: widget.products
                .map(
                  (p) => DropdownMenuItem<int>(
                    value: p.id,
                    child: Text('${p.name} (${p.quantity} available)', overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _productId = v);
            },
          ),
          AppCard(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current stock', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text('${_selected.quantity} units',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                if (preview != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('After saving', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                      const SizedBox(height: 2),
                      Text('$preview units',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green)),
                    ],
                  ),
              ],
            ),
          ),
          LabeledField(
            label: _quantityLabel,
            controller: _quantity,
            hint: 'Enter quantity',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            validator: _validateQuantity,
          ),
          LabeledField(
            label: 'Reason / reference',
            controller: _note,
            hint: _noteHint,
            maxLength: 255,
            validator: (v) => (v ?? '').trim().length > 255 ? 'Keep it under 255 characters' : null,
          ),
          FormError(_error),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: SaveLabel(saving: _saving, label: _confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
