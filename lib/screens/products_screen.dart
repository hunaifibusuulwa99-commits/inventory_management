import 'dart:async';

import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../utils/format.dart';
import '../widgets/app_card.dart';
import '../widgets/data_loader.dart';
import '../widgets/filter_chips.dart';
import '../widgets/page_title.dart';
import '../widgets/product_row.dart';
import '../widgets/state_views.dart';
import '../widgets/toast.dart';
import 'sheets/movement_sheet.dart';
import 'sheets/product_details_sheet.dart';
import 'sheets/product_form_sheet.dart';

/// Products tab: search, filter, view details, add, edit, delete.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.initialFilter = 'All'});

  final String initialFilter;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _products = ProductService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  late String _filter = widget.initialFilter;
  String _query = '';
  int _token = 0;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await CategoryService().list();
      if (!mounted) return;
      setState(() => _categories = list);
    } catch (_) {
      // The filter chips just show fewer options; the product list shows its own error.
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  void _refresh() => setState(() => _token++);

  Future<List<Product>> _load() async {
    int? categoryId;
    for (final c in _categories) {
      if (c.name == _filter) categoryId = c.id;
    }
    final lowOnly = _filter == 'Low stock' || _filter == 'Out of stock';
    var list = await _products.list(
      query: _query.isEmpty ? null : _query,
      categoryId: categoryId,
      lowStock: lowOnly ? true : null,
    );
    if (_filter == 'Low stock') list = list.where((p) => p.quantity > 0).toList();
    if (_filter == 'Out of stock') list = list.where((p) => p.quantity == 0).toList();
    return list;
  }

  Future<void> _add() async {
    final saved = await showProductFormSheet(context);
    if (saved == true && mounted) {
      _searchController.clear();
      setState(() {
        _query = '';
        _filter = 'All';
        _token++;
      });
    }
  }

  Future<void> _openDetails(Product product) async {
    final action = await showProductDetailsSheet(context, product);
    if (!mounted) return;
    switch (action) {
      case 'edit':
        final saved = await showProductFormSheet(context, product: product);
        if (saved == true) _refresh();
        break;
      case 'stock':
        final saved = await showMovementSheet(context, product: product);
        if (saved) _refresh();
        break;
      case 'deleted':
        showToast('Product deleted');
        _refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = ['All', 'Low stock', 'Out of stock', ..._categories.map((c) => c.name)];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(
                eyebrow: 'YOUR CATALOGUE',
                title: 'Products',
                actionLabel: 'Add',
                onAction: _add,
              ),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search product or SKU...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              FilterChips(
                options: options,
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: DataLoader<List<Product>>(
            refreshKey: '$_token|$_query|$_filter',
            load: _load,
            builder: (context, list, reload) => RefreshIndicator(
              onRefresh: reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: list.isEmpty
                        ? EmptyView(
                            emoji: '📦',
                            title: 'No products found',
                            message: _query.isEmpty && _filter == 'All'
                                ? 'Add your first product to get started.'
                                : 'Try another search or filter.',
                            actionLabel: 'Add product',
                            onAction: _add,
                          )
                        : Column(
                            children: withDividers([
                              for (final p in list)
                                ProductRow(product: p, onTap: () => _openDetails(p)),
                            ]),
                          ),
                  ),
                  if (list.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${list.length} product${list.length == 1 ? '' : 's'} · stock value '
                        '${formatMoney(list.fold<double>(0, (sum, p) => sum + p.stockValue))}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF748078)),
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
