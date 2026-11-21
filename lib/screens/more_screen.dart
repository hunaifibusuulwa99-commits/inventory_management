import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/server_settings_sheet.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'suppliers_screen.dart';

/// More tab: categories, suppliers, profile, settings, sign out.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 24),
      children: [
        const Text('MANAGE YOUR STORE', style: eyebrowStyle),
        const SizedBox(height: 5),
        const Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 17),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: withDividers([
              _MoreRow(
                icon: Icons.category_outlined,
                label: 'Categories',
                onTap: () => _open(context, const CategoriesScreen()),
              ),
              _MoreRow(
                icon: Icons.local_shipping_outlined,
                label: 'Suppliers',
                onTap: () => _open(context, const SuppliersScreen()),
              ),
              _MoreRow(
                icon: Icons.account_circle_outlined,
                label: 'Account & profile',
                onTap: () => _open(context, const ProfileScreen()),
              ),
              _MoreRow(
                icon: Icons.settings_outlined,
                label: 'Settings (server address)',
                onTap: () => showServerSettingsSheet(context),
              ),
            ]),
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STOCKWISE', style: eyebrowStyle),
              const SizedBox(height: 5),
              const Text('Inventory made simple.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Version 1.0.0 · Server: ${ApiClient.instance.baseUrl}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => AuthService().logout(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 21, color: AppColors.green),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
