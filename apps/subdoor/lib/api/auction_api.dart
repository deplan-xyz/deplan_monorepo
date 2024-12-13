import 'package:subdoor/api/base_api.dart';
import 'package:dio/dio.dart';

class _AuctionApi extends BaseApi {
  Future<Response> getAuctions({
    String? offerType,
    List<String>? statuses,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (offerType != null) {
      queryParams['offerType'] = offerType;
    }
    if (statuses != null) {
      queryParams['status'] = statuses;
    }
    return await client.get('/auctions', queryParameters: queryParams);
  }

  Future<Response> bid(String auctionId) async {
    return await client.post('/auctions/$auctionId/bid');
  }

  Future<Response> getBidHistory(String auctionId) async {
    return await client.get('/auctions/$auctionId/bid-history');
  }
}

final auctionApi = _AuctionApi();
