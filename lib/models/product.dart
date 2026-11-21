import '../utils/format.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.reorderLevel,
    required this.isLowStock,
  });

  final int id;
  final String name;
  final String sku;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final int? supplierId;
  final String? supplierName;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int reorderLevel;
  final bool isLowStock;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        sku: json['sku'] as String,
        description: json['description'] as String?,
        categoryId: (json['category_id'] as num?)?.toInt(),
        categoryName: json['category_name'] as String?,
        supplierId: (json['supplier_id'] as num?)?.toInt(),
        supplierName: json['supplier_name'] as String?,
        costPrice: (json['cost_price'] as num).toDouble(),
        sellingPrice: (json['selling_price'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
        reorderLevel: (json['reorder_level'] as num).toInt(),
        isLowStock: json['is_low_stock'] as bool,
      );

  bool get isOut => quantity <= 0;
  double get stockValue => quantity * sellingPrice;
  String get emoji => productEmoji(categoryName);
}
