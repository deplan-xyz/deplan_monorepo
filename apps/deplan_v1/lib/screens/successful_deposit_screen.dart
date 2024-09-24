import 'package:deplan/app_home.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/utils/numbers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuccessfulDepositScreen extends StatelessWidget {
  final double? amount;
  final String? address;

  const SuccessfulDepositScreen({super.key, this.amount, this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.checkmark_alt_circle,
            color: COLOR_GREEN,
            size: 150,
          ),
          const SizedBox(height: 30),
          Text(
            '\$${trimZeros(amount ?? 0)} deposited',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          Text(
            'Your money has been successfully deposited to ${address?.replaceRange(4, 40, '...')}',
            style: const TextStyle(color: COLOR_GRAY),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 70),
          Center(
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AppHome(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
