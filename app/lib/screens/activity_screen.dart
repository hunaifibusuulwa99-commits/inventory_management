import 'package:flutter/material.dart';

import '../models/stock_movement.dart';
import '../services/stock_service.dart';
import '../widgets/app_card.dart';
import '../widgets/data_loader.dart';
import '../widgets/filter_chips.dart';
import '../widgets/movement_row.dart';
import '../widgets/page_title.dart';
import '../widgets/state_views.dart';
import 'sheets/movement_sheet.dart';

/// Activity tab: history of every stock in / out / adjustment.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const Map<String, String?> _filters = {
    'All activity': null,
    'Stock in': 'in',
    'Stock out': 'out',
    'Adjustments': 'adjust',
  };

  String _filter = 'All activity';
  int _token = 0;

  Future<void> _record() async {
    final saved = await showMovementSheet(context);
    if (saved && mounted) setState(() => _token++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(
                eyebrow: 'INVENTORY LOG',
                title: 'Activity',
                actionLabel: 'Record',
                onAction: _record,
              ),
              FilterChips(
                options: _filters.keys.toList(),
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: DataLoader<List<StockMovement>>(
            refreshKey: '$_token|$_filter',
            load: () => StockService().list(type: _filters[_filter]),
            builder: (context, list, reload) => RefreshIndicator(
              onRefresh: reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    child: list.isEmpty
                        ? const EmptyView(
                            emoji: '🧾',
                            title: 'No stock activity yet',
                            message: 'Record stock coming in or going out and it will show here.',
                          )
                        : Column(
                            children: withDividers([
                              for (final m in list) MovementRow(movement: m),
                            ]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
