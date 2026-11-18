import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/toast.dart';
import 'activity_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';

/// The main app after login: top bar, the four tabs, and the bottom navigation.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  String _productFilter = 'All';
  Key _productsKey = UniqueKey();

  void _goTo(int tab, {String filter = 'All'}) {
    setState(() {
      _tab = tab;
      _productFilter = filter;
      _productsKey = UniqueKey(); // a new Products screen so the filter is applied
    });
  }

  Future<void> _showNotifications() async {
    try {
      final summary = await DashboardService().summary();
      final n = summary.lowStockCount;
      showToast(n == 0
          ? 'You are all caught up!'
          : '$n product${n == 1 ? '' : 's'} need${n == 1 ? 's' : ''} attention');
    } on ApiException catch (e) {
      showToast(e.message, error: true);
    }
  }

  Widget _body() {
    switch (_tab) {
      case 0:
        return HomeScreen(
          onViewStock: () => _goTo(1),
          onViewLowStock: () => _goTo(1, filter: 'Low stock'),
          onSeeActivity: () => _goTo(2),
          onProductAdded: () => _goTo(1),
        );
      case 1:
        return ProductsScreen(key: _productsKey, initialFilter: _productFilter);
      case 2:
        return const ActivityScreen();
      default:
        return const MoreScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onNotifications: _showNotifications,
              onProfile: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onSelected: (i) => _goTo(i),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotifications, required this.onProfile});

  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BrandName(),
          Row(
            children: [
              _IconBox(icon: Icons.notifications_none_rounded, onTap: onNotifications),
              const SizedBox(width: 8),
              _IconBox(icon: Icons.account_circle_outlined, onTap: onProfile),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onSelected});

  final int current;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
    (Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'Activity'),
    (Icons.menu_rounded, Icons.menu_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelected(i),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: i == current ? AppColors.navActive : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == current ? _items[i].$2 : _items[i].$1,
                            size: 23,
                            color: i == current ? AppColors.green : AppColors.navInactive,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _items[i].$3,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: i == current ? AppColors.green : AppColors.navInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
