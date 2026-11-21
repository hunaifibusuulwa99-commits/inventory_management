import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/labeled_field.dart';
import 'login_screen.dart' show emailPattern;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _business, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = AuthService();
    try {
      await auth.register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        businessName: _business.text.trim(),
      );
      // Account created: sign in straight away. The session change closes this screen.
      await auth.login(_email.text.trim(), _password.text);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F5),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create your account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                const SizedBox(height: 7),
                const Text('Set up your store and start tracking stock.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 22),
                LabeledField(
                  label: 'Full name',
                  controller: _name,
                  hint: 'e.g. Amina Nakato',
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.length < 2) return 'Enter your name (at least 2 characters)';
                    if (t.length > 100) return 'Must be at most 100 characters';
                    return null;
                  },
                ),
                LabeledField(
                  label: 'Business name (optional)',
                  controller: _business,
                  hint: 'e.g. Kampala Corner Shop',
                  maxLength: 150,
                  textInputAction: TextInputAction.next,
                ),
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
                  hint: 'At least 8 characters',
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  suffix: IconButton(
                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  ),
                  validator: (v) {
                    final t = v ?? '';
                    if (t.length < 8) return 'Use at least 8 characters';
                    if (t.length > 72) return 'Use at most 72 characters';
                    return null;
                  },
                ),
                LabeledField(
                  label: 'Confirm password',
                  controller: _confirm,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                ),
                FormError(_error),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                  child: SaveLabel(saving: _busy, label: 'Create account'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    TextButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
