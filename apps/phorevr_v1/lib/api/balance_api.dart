import 'package:dio/dio.dart';
import 'package:phorevr/api/base_api.dart';

class _BalanceApi extends BaseApi {
  Future<Response> getBalance() {
    return client.get('/balance');
  }

  Future<Response> deposit(double amount) {
    return client.post('/balance', data: {'amount': amount});
  }
}

final balanceApi = _BalanceApi();
