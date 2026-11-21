import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _api = ApiClient.instance;

  Future<List<Category>> list() async {
    final data = await _api.get('/categories', query: {'limit': 500}) as List<dynamic>;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Category> create({required String name, String? description}) async {
    final data = await _api.post('/categories', body: {'name': name, 'description': description});
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<Category> update(int id, {required String name, String? description}) async {
    final data = await _api.put('/categories/$id', body: {'name': name, 'description': description});
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/categories/$id');
  }
}
