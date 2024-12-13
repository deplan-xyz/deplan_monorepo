import 'package:subdoor/api/base_api.dart';
import 'package:dio/dio.dart';

class _UserApi extends BaseApi {
  Future<Response> getBalance() {
    return client.get('/user/balance');
  }

  Future<Response> getBids(int bids) {
    return client.post('/user/balance/bids', data: {'bids': bids});
  }

  Future<Response> getSubscriptions() {
    return client.get('/user/subscriptions');
  }

  Future<Response> getCardDetails(String subscriptionId) {
    return client.get('/user/subscriptions/$subscriptionId/card-details');
  }

  Future<Response> paySubscription(String subscriptionId) {
    return client.post('/user/subscriptions/$subscriptionId/payment');
  }

  Future<Response> topUpSubscription(String subscriptionId) {
    return client.post('/user/subscriptions/$subscriptionId/topup');
  }
}

final userApi = _UserApi();
