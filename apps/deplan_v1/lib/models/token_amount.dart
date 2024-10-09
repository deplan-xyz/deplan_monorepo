import 'package:deplan_core/utils/deplan_utils.dart';

class TokenAmount {
  String? amount;
  int? decimals;
  double? uiAmount;
  String? uiAmountString;

  TokenAmount({
    this.amount,
    this.decimals,
    this.uiAmount,
    this.uiAmountString,
  });

  TokenAmount.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    decimals = json['decimals'];
    uiAmount = intToDouble(json['uiAmount']);
    uiAmountString = json['uiAmountString'];
  }
}
