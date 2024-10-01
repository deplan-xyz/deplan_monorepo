class PaymentInfo {
  final double fullPrice;
  final double youPay;
  final double comission;
  PaymentInfo({
    required this.fullPrice,
    required this.youPay,
    required this.comission,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      fullPrice: json['fullPrice'].toDouble(),
      youPay: json['youPay'].toDouble(),
      comission: json['comission'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullPrice': fullPrice,
      'youPay': youPay,
      'comission': comission,
    };
  }
}

class PaymentInfoResponse {
  final PaymentInfo paymentInfo;

  PaymentInfoResponse({
    required this.paymentInfo,
  });

  factory PaymentInfoResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInfoResponse(
      paymentInfo: PaymentInfo.fromJson(json['paymentInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentInfo': paymentInfo.toJson(),
    };
  }
}
