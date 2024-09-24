import 'package:deplan_v1/screens/app_iframe_screen.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/widgets/buttons/icon_button_with_text.dart';

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

  showReceiveInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      builder: (context) {
        return SizedBox(
          height: 350,
          child: AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Receive DPLN',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Copy Your Solana Wallet Address',
                  style: TextStyle(
                    color: COLOR_GRAY,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () => handleCopyPressed(
                    context,
                    user?.wallet ?? '',
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          user?.wallet ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy, size: 30),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Only send DPLN on Solana network to this address!!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    color: COLOR_RED,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: () => showReceiveInfo(context),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => AppIframeScreen(
                  'https://solscan.io/address/${user?.wallet}',
                ),
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
              text: 'Receive',
              backgroundColor: COLOR_BLUE,
              onPressed: () => showReceiveInfo(context),
            ),
          ],
        ),
      ],
    );
  }
}
