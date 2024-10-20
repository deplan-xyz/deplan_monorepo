import 'package:deplan/api/base_api.dart';
import 'package:deplan/models/me.dart';
import 'package:deplan/models/organization.dart';
import 'package:deplan/models/payment_info.dart';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/models/subscription_details.dart';
import 'package:dio/dio.dart';

class API extends BaseApi {
  API() : super();

  Future<String> confirmSubscription(String orgId, String data) async {
    final response = await postRequest(
      '/events/subscription',
      body: {'orgId': orgId, 'data': data},
    );
    return response.data['paymentUrl'];
  }

  Future<Organization> getOrganizationById(String id) async {
    final response = await getRequest('/org/$id');
    return Organization.fromJson(response.data);
  }

  Future<List<Subscription>> listSubscriptions(num date) async {
    final response = await getRequest('/events?date=$date');
    return (response.data as List<dynamic>)
        .map((item) => Subscription.fromJson(item))
        .toList();
  }

  Future<List<SubscriptionDetailsModel>> subsciptionDetails(
    String orgId,
    num date,
  ) async {
    final response = await getRequest('/events/orgs/$orgId?date=$date');
    final fromJsonData = (response.data as List<dynamic>)
        .map((item) => SubscriptionDetailsModel.fromJson(item))
        .toList();
    return fromJsonData;
  }

  Future<PaymentInfoResponse> getPaymentInfo(num date) async {
    final response = await getRequest('/events/payment/info?date=$date');
    return PaymentInfoResponse.fromJson(response.data);
  }

  Future<String> getPaymentLink(num date) async {
    final response = await getRequest('/events/payment?date=$date');
    return response.data['paymentUrl'];
  }

  Future<UserResponse> getMe() async {
    final response = await getRequest('/auth/me');
    return UserResponse.fromJson(response.data);
  }

  Future<Response> refundSubscription() async {
    return postRequest('/events/refund');
  }

  Future<Response> getOrgEvents(String orgId) {
    return getRequest('/events/orgs/$orgId/types');
  }

  Future<Response> getEventsDemo(String orgId, Map<String, dynamic> data) {
    return postRequest('/events/orgs/$orgId/demo', body: data);
  }
}

final API api = API();
