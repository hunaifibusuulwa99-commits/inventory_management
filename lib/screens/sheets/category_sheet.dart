import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/api_client.dart';
import '../../services/category_service.dart';
import '../../theme.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/toast.dart';

/// Add / edit a category. Returns 'saved' or 'deleted' (null if closed without changes).
Future<String?> showCategorySheet(BuildContext context, {Category? category}) async {
  final result = await showAppSheet<String>(
    context,
    title: category == null ? 'Add category' : 'Edit category',
    builder: (_) => _CategoryForm(category: category),
  );
  if (result == 'saved') showToast('Category saved');
  if (result == 'deleted') showToast('Category deleted');
  return result;
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({this.category});

  final Category? category;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.category?.name ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.category?.description ?? '');
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.category != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final description = _description.text.trim();
    try {
      final service = CategoryService();
      if (_isEdit) {
        await service.update(widget.category!.id,
            name: _name.text.trim(), description: description.isEmpty ? null : description);
      } else {
        await service.create(
            name: _name.text.trim(), description: description.isEmpty ? null : description);
      }
      if (!mounted) return;
      Navigator.of(context).pop('saved');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Delete category?',
      message: 'Products in this category will be kept but will have no category.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await CategoryService().delete(widget.category!.id);
      if (!mounted) return;
      Navigator.of(context).pop('deleted');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Category name',
            controller: _name,
            hint: 'e.g. Accessories',
            maxLength: 80,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Category name is required';
              if (t.length > 80) return 'Must be at most 80 characters';
              return null;
            },
          ),
          LabeledField(
            label: 'Description (optional)',
            controller: _description,
            maxLength: 255,
            validator: (v) => (v ?? '').trim().length > 255 ? 'Keep it under 255 characters' : null,
          ),
          FormError(_error),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: SaveLabel(saving: _busy, label: 'Save category'),
                ),
              ),
            ],
          ),
          if (_isEdit) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Delete category', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
