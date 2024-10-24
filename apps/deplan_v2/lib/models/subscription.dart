import 'package:deplan_core/utils/deplan_utils.dart';

class Subscription {
  final String name;
  final double planPrice;
  final double youPay;
  final double usage;
  final String orgId;
  final String? username;
  final String? description;
  final String? logo;
  final int? usageCount;
  final String? link;

  Subscription({
    required this.name,
    required this.planPrice,
    required this.youPay,
    required this.usage,
    required this.orgId,
    this.username,
    this.description,
    this.usageCount,
    this.logo,
    this.link,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      orgId: json['orgId'],
      username: json['username'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
      planPrice: intToDouble(json['planPrice']) ?? 0,
      youPay: intToDouble(json['youPay']) ?? 0,
      usage: intToDouble(json['usage']) ?? 0,
      usageCount: json['usageCount'],
      link: json['link'],
    );
  }
}
