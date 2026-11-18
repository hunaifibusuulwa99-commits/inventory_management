import '../models/stock_movement.dart';
import 'api_client.dart';

class StockService {
  final ApiClient _api = ApiClient.instance;

  /// [type] is "in", "out" or "adjust" (null = all). Newest first.
  Future<List<StockMovement>> list({String? type, int? productId, int limit = 200}) async {
    final data = await _api.get('/stock-movements', query: {
      'movement_type': type,
      'product_id': productId,
      'limit': limit,
    }) as List<dynamic>;
    return data.map((e) => StockMovement.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StockMovement> create({
    required int productId,
    required String type,
    required int quantity,
    String? note,
  }) async {
    final data = await _api.post('/stock-movements', body: {
      'product_id': productId,
      'movement_type': type,
      'quantity': quantity,
      'note': (note == null || note.isEmpty) ? null : note,
    });
    return StockMovement.fromJson(data as Map<String, dynamic>);
  }
}
