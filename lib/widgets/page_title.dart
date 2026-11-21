import 'package:flutter/material.dart';

import '../theme.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: eyebrowStyle),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.7),
              ),
            ],
          ),
          if (actionLabel != null)
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
        ],
      ),
    );
  }
}
