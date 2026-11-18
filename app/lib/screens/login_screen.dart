import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/labeled_field.dart';
import '../widgets/server_settings_sheet.dart';
import 'register_screen.dart';

final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService().login(_email.text.trim(), _password.text);
      // On success the session changes and the app switches to the main screens.
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Server address',
                    icon: const Icon(Icons.settings_outlined, color: AppColors.muted),
                    onPressed: () => showServerSettingsSheet(context),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(alignment: Alignment.centerLeft, child: BrandLogo(size: 56)),
                const SizedBox(height: 22),
                const Text('Welcome back',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                const SizedBox(height: 7),
                const Text('Sign in to manage your inventory.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 26),
                LabeledField(
                  label: 'Email address',
                  controller: _email,
                  hint: 'you@business.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Enter your email';
                    if (!emailPattern.hasMatch(t)) return 'Enter a valid email';
                    return null;
                  },
                ),
                LabeledField(
                  label: 'Password',
                  controller: _password,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  ),
                  validator: (v) => (v ?? '').isEmpty ? 'Enter your password' : null,
                ),
                FormError(_error),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                  child: SaveLabel(saving: _busy, label: 'Sign in'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                      child: const Text('Create one'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Server: ${ApiClient.instance.baseUrl}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
