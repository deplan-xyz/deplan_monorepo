import 'package:dio/dio.dart';
import 'package:deplan_v1/api/base_api.dart';

class _BalanceApi extends BaseApi {
  Future<Response> getBalance() {
    return client.get('/balance/credits');
  }

  Future<Response> getHistory() {
    return client.get('/balance/credits/history');
  }

  Future<Response> deposit(double amount) {
    return client.post('/balance/credits', data: {'amount': amount});
  }
}

final balanceApi = _BalanceApi();
