import '../models/supplier.dart';
import 'api_client.dart';

class SupplierService {
  final ApiClient _api = ApiClient.instance;

  Future<List<Supplier>> list() async {
    final data = await _api.get('/suppliers', query: {'limit': 500}) as List<dynamic>;
    return data.map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Supplier> create(Map<String, dynamic> body) async =>
      Supplier.fromJson(await _api.post('/suppliers', body: body) as Map<String, dynamic>);

  Future<Supplier> update(int id, Map<String, dynamic> body) async =>
      Supplier.fromJson(await _api.put('/suppliers/$id', body: body) as Map<String, dynamic>);

  Future<void> delete(int id) async {
    await _api.delete('/suppliers/$id');
  }
}
