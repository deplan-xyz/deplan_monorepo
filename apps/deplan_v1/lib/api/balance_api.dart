import 'package:deplan_core/deplan_core.dart';
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

  Future<Response> withdraw(SendMoneyData sendMoneyData, [String? signedTxn]) {
    final data = sendMoneyData.toMap();
    if (signedTxn != null) {
      data['txn'] = signedTxn;
    }
    return client.post('/balance/withdraw', data: data);
  }
}

final balanceApi = _BalanceApi();
