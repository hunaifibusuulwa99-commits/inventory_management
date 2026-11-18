import 'package:flutter/material.dart';

import '../models/stock_movement.dart';
import '../theme.dart';
import '../utils/format.dart';

class MovementRow extends StatelessWidget {
  const MovementRow({super.key, required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final m = movement;
    final IconData icon;
    final Color color;
    final String amount;
    final String fallbackNote;
    switch (m.type) {
      case 'in':
        icon = Icons.south_west_rounded;
        color = AppColors.green;
        amount = '+${m.quantity}';
        fallbackNote = 'Stock received';
        break;
      case 'out':
        icon = Icons.north_east_rounded;
        color = AppColors.red;
        amount = '−${m.quantity}';
        fallbackNote = 'Stock issued';
        break;
      default:
        icon = Icons.sync_alt_rounded;
        color = AppColors.lowFg;
        amount = '= ${m.quantity}';
        fallbackNote = 'Stock count';
    }
    final note = (m.note == null || m.note!.isEmpty) ? fallbackNote : m.note!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$note · ${formatWhen(m.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
