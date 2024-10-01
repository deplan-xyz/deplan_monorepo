enum SendMoneyToken {
  USDC,
  DPLN,
}

class SendMoneyData {
  double? amount;
  String? recipient;
  SendMoneyToken? token;

  SendMoneyData({
    this.amount,
    this.recipient,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'recipient': recipient,
      'token': token?.name,
    };
  }
}
