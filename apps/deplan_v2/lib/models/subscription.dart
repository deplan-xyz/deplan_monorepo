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
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      orgId: json['orgId'],
      username: json['username'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
      planPrice: json['planPrice'],
      youPay: json['youPay'],
      usage: json['usage'],
      usageCount: json['usageCount'],
    );
  }
}
