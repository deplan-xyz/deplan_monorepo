class PaymentInfo {
  final double fullPrice;
  final double youPay;

  PaymentInfo({
    required this.fullPrice,
    required this.youPay,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      fullPrice: json['fullPrice'].toDouble(),
      youPay: json['youPay'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullPrice': fullPrice,
      'youPay': youPay,
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
