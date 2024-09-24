import 'package:deplan/models/user_balance.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deplan/models/user.dart';
import 'package:deplan/screens/account/components/account_wallet_section.dart';

class AccountHeader extends StatelessWidget {
  final UserBalance? balance;
  final User? user;

  const AccountHeader({super.key, this.balance, this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: balance == null
              ? const CupertinoActivityIndicator()
              : Column(
                  children: [
                    Text(
                      '\$${balance?.usdcBalance}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      '${balance?.nativeTokenBalance?.uiAmountString} DPLN',
                      style: const TextStyle(color: COLOR_GRAY),
                    ),
                  ],
                ),
        ),
        AccountWalletSection(user: user),
      ],
    );
  }
}
