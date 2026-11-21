import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import '../../services/api_client.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/supplier_service.dart';
import '../../theme.dart';
import '../../utils/async_utils.dart';
import '../../utils/format.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/data_loader.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/toast.dart';

/// Opens the add / edit product form. Returns true if the product was saved.
Future<bool?> showProductFormSheet(BuildContext context, {Product? product}) async {
  final saved = await showAppSheet<bool>(
    context,
    title: product == null ? 'Add product' : 'Edit product',
    builder: (_) => _ProductFormLoader(product: product),
  );
  if (saved == true) {
    showToast(product == null ? 'Product added successfully' : 'Product updated successfully');
  }
  return saved;
}

class _Lookups {
  const _Lookups(this.categories, this.suppliers);
  final List<Category> categories;
  final List<Supplier> suppliers;
}

class _ProductFormLoader extends StatelessWidget {
  const _ProductFormLoader({this.product});

  final Product? product;

  Future<_Lookups> _load() async {
    final (categories, suppliers) = await both(CategoryService().list(), SupplierService().list());
    return _Lookups(categories, suppliers);
  }

  @override
  Widget build(BuildContext context) {
    return DataLoader<_Lookups>(
      load: _load,
      builder: (context, data, _) =>
          _ProductForm(product: product, categories: data.categories, suppliers: data.suppliers),
    );
  }
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({this.product, required this.categories, required this.suppliers});

  final Product? product;
  final List<Category> categories;
  final List<Supplier> suppliers;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _description;
  late final TextEditingController _selling;
  late final TextEditingController _cost;
  late final TextEditingController _quantity;
  late final TextEditingController _reorder;
  int? _categoryId;
  int? _supplierId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _selling = TextEditingController(text: p == null ? '' : formatInput(p.sellingPrice));
    _cost = TextEditingController(text: p == null ? '' : formatInput(p.costPrice));
    _quantity = TextEditingController(text: '');
    _reorder = TextEditingController(text: p == null ? '5' : p.reorderLevel.toString());
    _categoryId = p?.categoryId;
    _supplierId = p?.supplierId;
    // The saved category/supplier might not be in the lists (deleted elsewhere): fall back to none.
    if (!widget.categories.any((c) => c.id == _categoryId)) _categoryId = null;
    if (!widget.suppliers.any((s) => s.id == _supplierId)) _supplierId = null;
  }

  @override
  void dispose() {
    for (final c in [_name, _sku, _description, _selling, _cost, _quantity, _reorder]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String what, {int? max}) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return '$what is required';
    if (max != null && text.length > max) return '$what must be at most $max characters';
    return null;
  }

  String? _money(String? v, {bool required = true}) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return required ? 'Enter a price' : null;
    final n = double.tryParse(text);
    if (n == null || n < 0) return 'Enter a valid amount';
    return null;
  }

  String? _wholeNumber(String? v, {bool required = true}) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return required ? 'Enter a number' : null;
    final n = int.tryParse(text);
    if (n == null || n < 0) return 'Enter a whole number (0 or more)';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final description = _description.text.trim();
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'sku': _sku.text.trim(),
      'description': description.isEmpty ? null : description,
      'category_id': _categoryId,
      'supplier_id': _supplierId,
      'cost_price': double.tryParse(_cost.text.trim()) ?? 0,
      'selling_price': double.parse(_selling.text.trim()),
      'reorder_level': int.parse(_reorder.text.trim()),
    };

    try {
      final service = ProductService();
      if (_isEdit) {
        await service.update(widget.product!.id, body);
      } else {
        body['quantity'] = int.tryParse(_quantity.text.trim()) ?? 0;
        await service.create(body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final money = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Product name',
            controller: _name,
            hint: 'e.g. Wireless Mouse',
            maxLength: 150,
            textInputAction: TextInputAction.next,
            validator: (v) => _required(v, 'Product name', max: 150),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'SKU',
                  controller: _sku,
                  hint: 'PR-001',
                  maxLength: 50,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _required(v, 'SKU', max: 50),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledDropdown<int?>(
                  label: 'Category',
                  value: _categoryId,
                  hint: const Text('None'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('None')),
                    ...widget.categories.map(
                      (c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
            ],
          ),
          LabeledDropdown<int?>(
            label: 'Supplier',
            value: _supplierId,
            hint: const Text('None'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('None')),
              ...widget.suppliers.map(
                (s) => DropdownMenuItem<int?>(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _supplierId = v),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Unit price (UGX)',
                  controller: _selling,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: money,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _money(v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'Cost price (UGX)',
                  controller: _cost,
                  hint: '0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: money,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _money(v, required: false),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEdit)
                Expanded(
                  child: LabeledField(
                    label: 'Opening quantity',
                    controller: _quantity,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _wholeNumber(v, required: false),
                  ),
                ),
              if (!_isEdit) const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'Low-stock threshold',
                  controller: _reorder,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  validator: (v) => _wholeNumber(v),
                ),
              ),
            ],
          ),
          if (_isEdit)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Current stock: ${widget.product!.quantity} units. '
                'To change it, close this form and use "Adjust stock".',
                style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4),
              ),
            ),
          LabeledField(
            label: 'Description (optional)',
            controller: _description,
            maxLength: 500,
            maxLines: 2,
            validator: (v) => (v ?? '').trim().length > 500 ? 'Keep it under 500 characters' : null,
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
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: SaveLabel(saving: _saving, label: _isEdit ? 'Save changes' : 'Add product'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
