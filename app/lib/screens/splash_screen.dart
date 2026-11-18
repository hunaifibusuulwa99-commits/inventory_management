import 'package:flutter/material.dart';

import '../services/session.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/server_settings_sheet.dart';

/// Shown while the app checks the saved login. If the server cannot be reached it offers
/// Retry, a way to change the server address, and a way to go back to the login screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.error});

  /// When set, the server could not be reached and this explains why.
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandLogo(size: 64),
                const SizedBox(height: 14),
                const Text('stockwise',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                const SizedBox(height: 4),
                const Text('Inventory made simple.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 28),
                if (error == null)
                  const CircularProgressIndicator(color: AppColors.green)
                else ...[
                  const Icon(Icons.cloud_off_rounded, color: AppColors.lowFg, size: 30),
                  const SizedBox(height: 10),
                  const Text("Can't reach the server",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: Session.instance.bootstrap,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try again'),
                    style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () async {
                      await showServerSettingsSheet(context);
                      Session.instance.bootstrap();
                    },
                    child: const Text('Change server address'),
                  ),
                  TextButton(
                    onPressed: Session.instance.signOut,
                    style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                    child: const Text('Go to sign in'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
