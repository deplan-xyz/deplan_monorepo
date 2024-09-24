import 'package:deplan/models/token_amount.dart';
import 'package:deplan/utils/numbers.dart';

class UserBalance {
  TokenAmount? nativeTokenBalance;
  double? usdcBalance;

  UserBalance.fromJson(Map json) {
    nativeTokenBalance = TokenAmount.fromJson(json['nativeTokenBalance']);
    usdcBalance = intToDouble(json['usdcBalance']);
  }
}
