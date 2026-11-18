import 'package:flutter_test/flutter_test.dart';
import 'package:stockwise/models/product.dart';
import 'package:stockwise/utils/format.dart';

void main() {
  test('formats money in UGX with thousands separators', () {
    expect(formatMoney(85000), 'UGX 85,000');
    expect(formatMoney(1250000), 'UGX 1,250,000');
    expect(formatMoney(0), 'UGX 0');
  });

  test('parses API dates (no timezone) as UTC', () {
    final d = parseApiDate('2026-11-08T10:42:00');
    expect(d.isUtc, isFalse); // converted to local time
    expect(d.toUtc().hour, 10);
  });

  test('Product.fromJson reads the API response', () {
    final p = Product.fromJson({
      'id': 1,
      'name': 'Soda 300ml',
      'sku': 'DRK-002',
      'description': null,
      'category_id': 2,
      'category_name': 'Drinks',
      'supplier_id': null,
      'supplier_name': null,
      'cost_price': 1000,
      'selling_price': 1500.0,
      'quantity': 8,
      'reorder_level': 20,
      'is_low_stock': true,
    });
    expect(p.isLowStock, isTrue);
    expect(p.isOut, isFalse);
    expect(p.stockValue, 12000);
    expect(p.emoji, '🥤');
  });
}
