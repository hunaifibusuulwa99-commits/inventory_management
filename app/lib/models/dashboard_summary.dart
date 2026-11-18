import 'stock_movement.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalSuppliers,
    required this.totalUnits,
    required this.stockValueAtCost,
    required this.stockValueAtSellingPrice,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.recentMovements,
  });

  final int totalProducts;
  final int totalCategories;
  final int totalSuppliers;
  final int totalUnits;
  final double stockValueAtCost;
  final double stockValueAtSellingPrice;
  final int lowStockCount;
  final int outOfStockCount;
  final List<StockMovement> recentMovements;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        totalProducts: (json['total_products'] as num).toInt(),
        totalCategories: (json['total_categories'] as num).toInt(),
        totalSuppliers: (json['total_suppliers'] as num).toInt(),
        totalUnits: (json['total_units'] as num).toInt(),
        stockValueAtCost: (json['stock_value_at_cost'] as num).toDouble(),
        stockValueAtSellingPrice: (json['stock_value_at_selling_price'] as num).toDouble(),
        lowStockCount: (json['low_stock_count'] as num).toInt(),
        outOfStockCount: (json['out_of_stock_count'] as num).toInt(),
        recentMovements: (json['recent_movements'] as List<dynamic>)
            .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
