import 'package:subdoor/models/token_amount.dart';

class UserBalance {
  final TokenAmount nativeTokenBalance;
  final TokenAmount usdcBalance;
  final int bidBalance;

  UserBalance({
    required this.nativeTokenBalance,
    required this.usdcBalance,
    required this.bidBalance,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      nativeTokenBalance: TokenAmount.fromJson(json['nativeTokenBalance']),
      usdcBalance: TokenAmount.fromJson(json['usdcBalance']),
      bidBalance: json['bidBalance'],
    );
  }

  UserBalance copyWith({
    int? bidBalance,
  }) {
    return UserBalance(
      nativeTokenBalance: nativeTokenBalance,
      usdcBalance: usdcBalance,
      bidBalance: bidBalance ?? this.bidBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nativeTokenBalance': nativeTokenBalance.toJson(),
      'usdcBalance': usdcBalance.toJson(),
      'bidBalance': bidBalance,
    };
  }
}
