import 'package:subdoor/api/auth_api.dart';
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
    if (authApi.wallet == null) {
      return client.post('/user/subscriptions/$subscriptionId/payment');
    } else {
      return _paySubscriptionSolana(subscriptionId);
    }
  }

  Future<Response> topUpSubscription(String subscriptionId) {
    if (authApi.wallet == null) {
      return client.post('/user/subscriptions/$subscriptionId/topup');
    } else {
      return _topUpSubscriptionSolana(subscriptionId);
    }
  }

  Future<Response> _paySubscriptionSolana(String subscriptionId) async {
    Response response = await client.post(
      '/user/subscriptions/$subscriptionId/payment/solana',
    );

    final tx = await authApi.wallet!.signTransaction(response.data['tx']);

    response = await client.post(
      '/user/subscriptions/$subscriptionId/payment/solana',
      data: {'tx': tx},
    );

    return response;
  }

  Future<Response> _topUpSubscriptionSolana(String subscriptionId) async {
    Response response = await client.post(
      '/user/subscriptions/$subscriptionId/topup/solana',
    );

    final tx = await authApi.wallet!.signTransaction(response.data['tx']);

    response = await client.post(
      '/user/subscriptions/$subscriptionId/topup/solana',
      data: {'tx': tx},
    );

    return response;
  }
}

final userApi = _UserApi();
