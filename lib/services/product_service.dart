import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _api = ApiClient.instance;

  List<Product> _parse(dynamic data) =>
      (data as List<dynamic>).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<Product>> list({
    String? query,
    int? categoryId,
    int? supplierId,
    bool? lowStock,
    int limit = 500,
  }) async {
    final data = await _api.get('/products', query: {
      'q': query,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'low_stock': lowStock,
      'limit': limit,
    });
    return _parse(data);
  }

  /// Products at or below their reorder level (includes out of stock), lowest first.
  Future<List<Product>> lowStock() async => _parse(await _api.get('/products/low-stock'));

  Future<Product> create(Map<String, dynamic> body) async =>
      Product.fromJson(await _api.post('/products', body: body) as Map<String, dynamic>);

  Future<Product> update(int id, Map<String, dynamic> body) async =>
      Product.fromJson(await _api.put('/products/$id', body: body) as Map<String, dynamic>);

  Future<void> delete(int id) async {
    await _api.delete('/products/$id');
  }
}
