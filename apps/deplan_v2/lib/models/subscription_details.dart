class SubscriptionDetailsModel {
  final String orgId;
  final String userId;
  final num month;
  final String username;
  final String name;
  final String description;
  final String logo;
  final num planPrice;
  final num youPay;
  final num usage;
  final int usageCount;
  final Map<String, List<num>> usagePerMonth;
  final List<Map<String, num>> eventsByDay;

  SubscriptionDetailsModel({
    required this.orgId,
    required this.userId,
    required this.month,
    required this.username,
    required this.name,
    required this.description,
    required this.logo,
    required this.planPrice,
    required this.youPay,
    required this.usage,
    required this.usageCount,
    required this.usagePerMonth,
    this.eventsByDay = const [],
  });

  factory SubscriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    final usagePerMonth = Map<String, List<num>>.from(json['usagePerMonth'].map(
      (key, value) => MapEntry(key, List<num>.from(value)),
    ),);

    return SubscriptionDetailsModel(
      orgId: json['orgId'],
      userId: json['userId'],
      month: json['month'],
      username: json['username'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
      planPrice: json['planPrice'].toDouble(),
      youPay: json['youPay'].toDouble(),
      usage: json['usage'].toDouble(),
      usageCount: json['usageCount'],
      usagePerMonth: usagePerMonth,
      eventsByDay: buildUsageSummary(usagePerMonth),
    );
  }
}

List<Map<String, num>> buildUsageSummary(Map<String, List<num>> usage) {
  // Determine the length of the lists (assuming all lists are of the same length)
  int length = 0;

  try {
    length = usage.values.first.length;
  } catch (e) {
    print(e);
  }

  List<String> keys = usage.keys.toList();

  // Prepare the list of maps to return
  List<Map<String, num>> usageSummary = List.generate(length, (_) => {});

  for (int i = 0; i < length; i++) {
    for (String key in keys) {
      usageSummary[i][key] = usage[key]![i];
    }
  }

  // Iterate through each key-value pair in the map

  return usageSummary;
}
