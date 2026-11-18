import 'package:flutter/material.dart';

import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/data_loader.dart';
import '../widgets/page_title.dart';
import '../widgets/state_views.dart';
import '../widgets/sub_page_app_bar.dart';
import 'sheets/supplier_sheet.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  int _token = 0;

  Future<void> _open([Supplier? supplier]) async {
    final result = await showSupplierSheet(context, supplier: supplier);
    if (result != null && mounted) setState(() => _token++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subPageAppBar(context),
      body: DataLoader<List<Supplier>>(
        refreshKey: _token,
        load: () => SupplierService().list(),
        builder: (context, list, reload) => RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 24),
            children: [
              PageTitle(
                eyebrow: 'YOUR PARTNERS',
                title: 'Suppliers',
                actionLabel: 'Add',
                onAction: _open,
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: list.isEmpty
                    ? EmptyView(
                        emoji: '🏢',
                        title: 'No suppliers yet',
                        message: 'Add the businesses you buy your stock from.',
                        actionLabel: 'Add supplier',
                        onAction: _open,
                      )
                    : Column(
                        children: withDividers([
                          for (final s in list)
                            InkWell(
                              onTap: () => _open(s),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  children: [
                                    const Text('🏢', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14)),
                                          if (s.phone != null && s.phone!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(s.phone!,
                                                  style: const TextStyle(
                                                      fontSize: 11, color: AppColors.muted)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${s.productCount} product${s.productCount == 1 ? '' : 's'}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Edit',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.green)),
                                  ],
                                ),
                              ),
                            ),
                        ]),
                      ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('← Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
