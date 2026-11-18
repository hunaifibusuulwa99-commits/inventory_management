import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../models/product.dart';
import '../services/dashboard_service.dart';
import '../services/product_service.dart';
import '../services/session.dart';
import '../theme.dart';
import '../utils/async_utils.dart';
import '../utils/format.dart';
import '../widgets/app_card.dart';
import '../widgets/badges.dart';
import '../widgets/data_loader.dart';
import '../widgets/movement_row.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import 'sheets/movement_sheet.dart';
import 'sheets/product_form_sheet.dart';

class _HomeData {
  const _HomeData(this.summary, this.lowStock);

  final DashboardSummary summary;
  final List<Product> lowStock;
}

/// Dashboard tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onViewStock,
    required this.onViewLowStock,
    required this.onSeeActivity,
    required this.onProductAdded,
  });

  final VoidCallback onViewStock;
  final VoidCallback onViewLowStock;
  final VoidCallback onSeeActivity;
  final VoidCallback onProductAdded;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _token = 0;

  Future<_HomeData> _load() async {
    final (summary, low) = await both(DashboardService().summary(), ProductService().lowStock());
    return _HomeData(summary, low);
  }

  Future<void> _addProduct() async {
    final saved = await showProductFormSheet(context);
    if (saved == true) widget.onProductAdded();
  }

  Future<void> _recordStock(String type) async {
    final saved = await showMovementSheet(context, type: type);
    if (saved && mounted) setState(() => _token++);
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.instance.user;
    final first = user?.firstName ?? '';
    final business = user?.businessName;

    return DataLoader<_HomeData>(
      refreshKey: _token,
      load: _load,
      builder: (context, data, reload) {
        final s = data.summary;
        final lowCount = data.lowStock.where((p) => p.quantity > 0).length;
        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatLongDate(DateTime.now()), style: eyebrowStyle),
                        const SizedBox(height: 4),
                        Text(
                          '${greeting()}${first.isEmpty ? '' : ', $first'} 👋',
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          business == null || business.isEmpty
                              ? "Here's what's happening with your store."
                              : "Here's what's happening at $business.",
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AppBadge(text: '● Live'),
                ],
              ),
              const SizedBox(height: 17),
              _HeroCard(
                value: s.stockValueAtSellingPrice,
                productCount: s.totalProducts,
                onViewStock: widget.onViewStock,
              ),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Total products',
                      value: '${s.totalProducts}',
                      caption: 'In your catalogue',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Low stock',
                      value: '$lowCount',
                      caption: 'Need attention',
                      icon: Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Stock units',
                      value: formatNumber(s.totalUnits),
                      caption: 'Units available',
                      icon: Icons.grid_view_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Out of stock',
                      value: '${s.outOfStockCount}',
                      caption: 'Products unavailable',
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SectionHeader(title: 'Quick actions'),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_rounded,
                      label: 'Add product',
                      onTap: _addProduct,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.south_west_rounded,
                      label: 'Stock in',
                      onTap: () => _recordStock('in'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.north_east_rounded,
                      label: 'Stock out',
                      onTap: () => _recordStock('out'),
                    ),
                  ),
                ],
              ),
              SectionHeader(
                title: 'Low stock alerts',
                actionLabel: 'View all',
                onAction: widget.onViewLowStock,
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: data.lowStock.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'All products are sufficiently stocked.',
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    : Column(
                        children: withDividers([
                          for (final p in data.lowStock.take(3))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '⚠️  ${p.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppBadge(
                                    text: p.isOut ? 'Out of stock' : '${p.quantity} left',
                                    background: p.isOut ? AppColors.outBg : AppColors.lowBg,
                                    foreground: p.isOut ? AppColors.outFg : AppColors.lowFg,
                                  ),
                                ],
                              ),
                            ),
                        ]),
                      ),
              ),
              SectionHeader(
                title: 'Recent activity',
                actionLabel: 'See all',
                onAction: widget.onSeeActivity,
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: s.recentMovements.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No stock activity yet.',
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    : Column(
                        children: withDividers([
                          for (final m in s.recentMovements.take(3)) MovementRow(movement: m),
                        ]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.value, required this.productCount, required this.onViewStock});

  final double value;
  final int productCount;
  final VoidCallback onViewStock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.heroStart, AppColors.heroEnd],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -42,
                top: -55,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x30FFFFFF)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL INVENTORY VALUE',
                        style: eyebrowStyle.copyWith(color: const Color(0xFFD4EEE1))),
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  formatMoney(value),
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.7,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Across $productCount product${productCount == 1 ? '' : 's'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFFD9F0E4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: onViewStock,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('View stock →'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.green, size: 23),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
