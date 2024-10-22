class EventsDemo {
  final double planPrice;
  final double youPay;
  final double usage;

  EventsDemo({
    required this.planPrice,
    required this.youPay,
    required this.usage,
  });

  factory EventsDemo.fromJson(Map<String, dynamic> json) {
    return EventsDemo(
      planPrice: json['planPrice'].toDouble(),
      youPay: json['youPay'].toDouble(),
      usage: json['usage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planPrice': planPrice,
      'youPay': youPay,
      'usage': usage,
    };
  }
}
