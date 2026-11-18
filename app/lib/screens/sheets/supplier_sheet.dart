import 'package:flutter/material.dart';

import '../../models/supplier.dart';
import '../../services/api_client.dart';
import '../../services/supplier_service.dart';
import '../../theme.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/toast.dart';

/// Add / edit a supplier. Returns 'saved' or 'deleted' (null if closed without changes).
Future<String?> showSupplierSheet(BuildContext context, {Supplier? supplier}) async {
  final result = await showAppSheet<String>(
    context,
    title: supplier == null ? 'Add supplier' : 'Edit supplier',
    builder: (_) => _SupplierForm(supplier: supplier),
  );
  if (result == 'saved') showToast('Supplier saved');
  if (result == 'deleted') showToast('Supplier deleted');
  return result;
}

class _SupplierForm extends StatefulWidget {
  const _SupplierForm({this.supplier});

  final Supplier? supplier;

  @override
  State<_SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<_SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.supplier?.name ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.supplier?.phone ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.supplier?.email ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.supplier?.address ?? '');
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.supplier != null;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'phone': _orNull(_phone),
      'email': _orNull(_email),
      'address': _orNull(_address),
    };
    try {
      final service = SupplierService();
      if (_isEdit) {
        await service.update(widget.supplier!.id, body);
      } else {
        await service.create(body);
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
      title: 'Delete supplier?',
      message: 'Products from this supplier will be kept but will have no supplier.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SupplierService().delete(widget.supplier!.id);
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
            label: 'Supplier name',
            controller: _name,
            hint: 'Business or contact name',
            maxLength: 120,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Supplier name is required';
              if (t.length > 120) return 'Must be at most 120 characters';
              return null;
            },
          ),
          LabeledField(
            label: 'Phone (optional)',
            controller: _phone,
            hint: '+256 7XX XXX XXX',
            maxLength: 30,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          LabeledField(
            label: 'Email (optional)',
            controller: _email,
            hint: 'sales@supplier.com',
            maxLength: 255,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return null;
              return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email';
            },
          ),
          LabeledField(
            label: 'Address (optional)',
            controller: _address,
            maxLength: 255,
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
                  child: SaveLabel(saving: _busy, label: 'Save supplier'),
                ),
              ),
            ],
          ),
          if (_isEdit) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Delete supplier', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
