import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/data_loader.dart';
import '../widgets/page_title.dart';
import '../widgets/state_views.dart';
import '../widgets/sub_page_app_bar.dart';
import 'sheets/category_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _token = 0;

  Future<void> _open([Category? category]) async {
    final result = await showCategorySheet(context, category: category);
    if (result != null && mounted) setState(() => _token++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subPageAppBar(context),
      body: DataLoader<List<Category>>(
        refreshKey: _token,
        load: () => CategoryService().list(),
        builder: (context, list, reload) => RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 24),
            children: [
              PageTitle(
                eyebrow: 'ORGANISE PRODUCTS',
                title: 'Categories',
                actionLabel: 'Add',
                onAction: _open,
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: list.isEmpty
                    ? EmptyView(
                        emoji: '📁',
                        title: 'No categories yet',
                        message: 'Group your products, for example Drinks or Electronics.',
                        actionLabel: 'Add category',
                        onAction: _open,
                      )
                    : Column(
                        children: withDividers([
                          for (final c in list)
                            InkWell(
                              onTap: () => _open(c),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  children: [
                                    const Text('📁', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Text(c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14)),
                                    ),
                                    Text(
                                      '${c.productCount} product${c.productCount == 1 ? '' : 's'}',
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
