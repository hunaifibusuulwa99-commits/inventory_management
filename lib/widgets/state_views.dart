import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme.dart';
import 'server_settings_sheet.dart';

/// Shown while data is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppColors.green),
      ),
    );
  }
}

/// Shown when a request fails. Includes the "server is off" case required by the capstone.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final e = error;
    final network = e is ApiException && e.isNetwork;
    final message = e is ApiException ? e.message : 'Something went wrong. Please try again.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.lowBg, shape: BoxShape.circle),
              child: Icon(
                network ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
                color: AppColors.lowFg,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              network ? "Can't reach the server" : 'Something went wrong',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.35),
            ),
            if (network) ...[
              const SizedBox(height: 8),
              Text(
                'Server: ${ApiClient.instance.baseUrl}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(minimumSize: const Size(150, 44)),
            ),
            if (network)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () async {
                    await showServerSettingsSheet(context);
                    onRetry();
                  },
                  child: const Text('Change server address'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a list has nothing in it.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String emoji;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
