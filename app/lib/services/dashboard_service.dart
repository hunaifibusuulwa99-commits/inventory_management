import '../models/dashboard_summary.dart';
import 'api_client.dart';

class DashboardService {
  final ApiClient _api = ApiClient.instance;

  Future<DashboardSummary> summary() async =>
      DashboardSummary.fromJson(await _api.get('/dashboard/summary') as Map<String, dynamic>);
}
