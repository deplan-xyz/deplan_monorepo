class TokenAmount {
  final String amount;
  final int decimals;
  final double uiAmount;
  final String uiAmountString;

  TokenAmount({
    required this.amount,
    required this.decimals,
    required this.uiAmount,
    required this.uiAmountString,
  });

  factory TokenAmount.fromJson(Map<String, dynamic> json) {
    return TokenAmount(
      amount: json['amount'],
      decimals: json['decimals'],
      uiAmount: json['uiAmount'].toDouble(),
      uiAmountString: json['uiAmountString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'decimals': decimals,
      'uiAmount': uiAmount,
      'uiAmountString': uiAmountString,
    };
  }
}
