import 'package:flutter/cupertino.dart';
import 'package:phorevr_v1/theme/app_theme.dart';

class AccountTitleShimmer extends StatelessWidget {
  const AccountTitleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: COLOR_LIGHT_GRAY,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 60,
          height: 10,
          decoration: const BoxDecoration(
            color: COLOR_LIGHT_GRAY,
          ),
        ),
      ],
    );
  }
}
