import 'package:flutter/material.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/screens/account/components/account_wallet_section.dart';

class AccountHeader extends StatelessWidget {
  final String? balance;
  final User? user;

  const AccountHeader({super.key, this.balance, this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: balance == null
                ? const CircularProgressIndicator.adaptive()
                : Text(
                    '\$$balance',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
          ),
        ),
        AccountWalletSection(user: user),
      ],
    );
  }
}
