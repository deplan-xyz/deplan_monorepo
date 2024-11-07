import 'package:flutter/material.dart';
import 'package:deplan_core/deplan_core.dart';
import 'package:deplan_v1/app_home.dart';
import 'package:deplan_v1/theme/app_theme.dart';

class WithdrawSuccessScreen<T extends Widget> extends StatelessWidget {
  final SendMoneyData sendMoneyData;

  const WithdrawSuccessScreen({
    Key? key,
    required this.sendMoneyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_outlined,
              color: COLOR_GREEN,
              size: 200,
            ),
            const SizedBox(height: 30),
            Text(
              'Your withdrawal was submitted',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AppHome(),
                    ),
                    (_) => false,
                  );
                },
                child: const Text('Go to your account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
