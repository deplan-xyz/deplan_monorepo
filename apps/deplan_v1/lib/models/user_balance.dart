import 'package:deplan_core/utils/deplan_utils.dart';
import 'package:deplan_v1/models/token_amount.dart';

class UserBalance {
  TokenAmount? nativeTokenBalance;
  double? usdcBalance;

  UserBalance.fromJson(Map json) {
    nativeTokenBalance = TokenAmount.fromJson(json['nativeTokenBalance']);
    usdcBalance = intToDouble(json['usdcBalance']);
  }
}
