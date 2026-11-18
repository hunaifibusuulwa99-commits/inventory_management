import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme.dart';
import 'app_sheet.dart';
import 'labeled_field.dart';
import 'toast.dart';

/// Lets the user point the app at the laptop running the backend.
Future<void> showServerSettingsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Server address',
    builder: (_) => const _ServerSettingsBody(),
  );
}

class _ServerSettingsBody extends StatefulWidget {
  const _ServerSettingsBody();

  @override
  State<_ServerSettingsBody> createState() => _ServerSettingsBodyState();
}

class _ServerSettingsBodyState extends State<_ServerSettingsBody> {
  final _controller = TextEditingController(text: ApiClient.instance.baseUrl);
  bool _testing = false;
  String? _result;
  bool _ok = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    final previous = ApiClient.instance.baseUrl;
    setState(() {
      _testing = true;
      _result = null;
    });
    try {
      await ApiClient.instance.setBaseUrl(_controller.text);
      await ApiClient.instance.get('/health', auth: false);
      if (!mounted) return;
      setState(() {
        _ok = true;
        _result = 'Connected. The server is running.';
      });
    } on ApiException catch (e) {
      await ApiClient.instance.setBaseUrl(previous);
      if (!mounted) return;
      setState(() {
        _ok = false;
        _result = e.message;
      });
    }
    if (mounted) setState(() => _testing = false);
  }

  Future<void> _save() async {
    await ApiClient.instance.setBaseUrl(_controller.text);
    if (!mounted) return;
    Navigator.of(context).pop();
    showToast('Server address saved');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledField(
          label: 'Backend address',
          controller: _controller,
          hint: 'http://192.168.1.5:8000',
          keyboardType: TextInputType.url,
        ),
        const Text(
          'Android emulator: http://10.0.2.2:8000\n'
          'Real phone: http://<laptop-ip>:8000 (same Wi-Fi as the laptop)',
          style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.5),
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _result!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ok ? AppColors.green : AppColors.red,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _testing ? null : _test,
                child: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.green),
                      )
                    : const Text('Test connection'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
          ],
        ),
      ],
    );
  }
}
