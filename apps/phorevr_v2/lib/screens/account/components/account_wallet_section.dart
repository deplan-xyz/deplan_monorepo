import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/screens/account/deposit_amount_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/widgets/buttons/icon_button_with_text.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountWalletSection extends StatelessWidget {
  final User? user;

  const AccountWalletSection({super.key, this.user});

  callSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  handleCopyPressed(BuildContext context, String? text) async {
    Clipboard.setData(ClipboardData(text: text ?? ''));
    callSnackBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: () => handleCopyPressed(context, user?.wallet),
            style: const ButtonStyle(
              visualDensity: VisualDensity(vertical: 1),
            ),
            icon: SvgPicture.asset(
              'assets/icons/wallet.svg',
              width: 30,
            ),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solana Address',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: COLOR_GRAY, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.wallet?.replaceRange(8, 36, '...') ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.copy,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            launchUrl(
              Uri.parse(
                'https://solscan.io/address/${user?.wallet}',
              ),
            );
          },
          child: const Text(
            'View your wallet on blockchain »',
            style: TextStyle(
              color: COLOR_GRAY,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButtonWithText(
              image: SvgPicture.asset('assets/icons/money_box.svg'),
              text: 'Deposit',
              backgroundColor: COLOR_BLUE,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DepositAmountScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
