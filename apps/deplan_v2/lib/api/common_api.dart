import 'package:deplan/api/base_api.dart';
import 'package:deplan/models/me.dart';
import 'package:deplan/models/organization.dart';
import 'package:deplan/models/payment_info.dart';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/models/subscription_details.dart';
import 'package:dio/dio.dart';

class API extends BaseApi {
  API() : super();

  Future<Response> confirmSubscription(String orgId, String data) async {
    return await postRequest(
      '/events/subscription',
      body: {'orgId': orgId, 'data': data},
    );
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
      String orgId, num date) async {
    final response = await getRequest('/events/orgs/$orgId?date=$date');
    final fromJsonData = (response.data as List<dynamic>)
        .map((item) => SubscriptionDetailsModel.fromJson(item))
        .toList();
    return fromJsonData;
  }

  Future<PaymentInfoResponse> getPaymentInfo() async {
    final response = await getRequest('/events/payment/info');
    return PaymentInfoResponse.fromJson(response.data);
  }

  Future<String> getPaymentLink() async {
    final response = await getRequest('/events/payment');
    return response.data["paymentUrl"];
  }

  Future<UserResponse> getMe() async {
    final response = await getRequest('/auth/me');
    return UserResponse.fromJson(response.data);
  }
}

final API api = API();
