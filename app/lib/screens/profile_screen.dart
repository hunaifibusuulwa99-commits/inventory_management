import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/app_card.dart';
import '../widgets/sub_page_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.instance.user;
    final business = user?.businessName;

    return Scaffold(
      appBar: subPageAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 24),
        children: [
          const Text('PERSONAL SETTINGS', style: eyebrowStyle),
          const SizedBox(height: 5),
          const Text('My profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 15),
          AppCard(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    user?.initial ?? '?',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user?.fullName ?? '—',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(user?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: withDividers([
                _row('Business name', (business == null || business.isEmpty) ? '—' : business),
                _row('Currency', 'UGX (USh)'),
                _row('Account type', 'Business owner'),
                if (user?.createdAt != null) _row('Member since', formatDate(user!.createdAt!)),
                _row('Server', ApiClient.instance.baseUrl),
              ]),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => AuthService().logout(),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign out'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Signing out deletes your login token from this phone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
