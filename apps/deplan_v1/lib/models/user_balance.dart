import 'package:deplan_v1/models/token_amount.dart';
import 'package:deplan_v1/utils/numbers.dart';

class UserBalance {
  TokenAmount? nativeTokenBalance;
  double? usdcBalance;

  UserBalance.fromJson(Map json) {
    nativeTokenBalance = TokenAmount.fromJson(json['nativeTokenBalance']);
    usdcBalance = intToDouble(json['usdcBalance']);
  }
}
