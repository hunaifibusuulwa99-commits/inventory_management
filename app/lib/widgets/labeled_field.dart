import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

const TextStyle _labelStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF435149));

/// Text field with its label above it (like the prototype's form groups).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.inputFormatters,
    this.suffix,
    this.textInputAction,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final bool enabled;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            enabled: enabled,
            onFieldSubmitted: onFieldSubmitted,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(hintText: hint, counterText: '', suffixIcon: suffix),
          ),
        ],
      ),
    );
  }
}

/// Dropdown with its label above it.
class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T value;
  final Widget? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 6),
          InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: hint,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red message shown above a form's buttons when the server rejects the data.
class FormError extends StatelessWidget {
  const FormError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.outBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        message!,
        style: const TextStyle(fontSize: 12, color: AppColors.outFg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Button content that swaps to a spinner while saving.
class SaveLabel extends StatelessWidget {
  const SaveLabel({super.key, required this.saving, required this.label});

  final bool saving;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!saving) return Text(label);
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.green),
    );
  }
}
