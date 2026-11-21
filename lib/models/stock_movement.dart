import '../utils/format.dart';

/// movement type: "in", "out" or "adjust"
class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.quantityAfter,
    this.note,
    required this.createdAt,
  });

  final int id;
  final int productId;
  final String productName;
  final String type;
  final int quantity;
  final int quantityAfter;
  final String? note;
  final DateTime createdAt;

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: (json['id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
        productName: json['product_name'] as String,
        type: json['movement_type'] as String,
        quantity: (json['quantity'] as num).toInt(),
        quantityAfter: (json['quantity_after'] as num).toInt(),
        note: json['note'] as String?,
        createdAt: parseApiDate(json['created_at'] as String),
      );
}
