import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/text_copy.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/pages/wallet/add_bids_screen.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deplan_core/utils/deplan_utils.dart'
    if (dart.library.js_interop) 'dart:html' show window;

class WalletScreen extends StatefulWidget {
  final User user;
  final UserBalance userBalance;

  const WalletScreen({
    super.key,
    required this.user,
    required this.userBalance,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late UserBalance userBalance;

  @override
  void initState() {
    super.initState();
    userBalance = widget.userBalance;
  }

  Future<void> refreshBalance() async {
    final response = await userApi.getBalance();
    final balance = UserBalance.fromJson(response.data['balance']);
    setState(() {
      userBalance = balance;
    });
  }

  void showReceiveInfo(
    BuildContext context,
    String title,
    String logo,
    String description,
  ) {
    showAppBottomSheet(
      context,
      (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/$logo.png',
                      width: 28,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => copyText(context, widget.user.wallet),
              icon: const Icon(Icons.copy),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Copy Your Solana Wallet Address',
                    style: TextStyle(
                      color: Color(0xff87899B),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.user.wallet,
                  ),
                ],
              ),
              iconAlignment: IconAlignment.end,
            ),
            const SizedBox(height: 40),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                color: Color(0xffE93027),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildCurrencyBalance(
    BuildContext context,
    String balance,
    String name,
    String logo, {
    String? title,
    String? description,
    VoidCallback? onPressed,
  }) {
    return BodyPadding(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset(
            'assets/images/$logo.png',
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'sfprod',
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: Color(0xff11243E),
                height: 1,
              ),
              children: [
                TextSpan(text: balance),
                TextSpan(
                  text: ' $name',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xff00A310),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: onPressed ??
                  () => showReceiveInfo(
                        context,
                        title ?? '',
                        logo,
                        description ?? '',
                      ),
              child: const Text(
                '+ ADD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'sfprodbold',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: refreshBalance,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => copyText(context, widget.user.wallet),
                    icon: Image.asset(
                      'assets/images/wallet.png',
                      width: 28.67,
                      height: 28.67,
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.comfortable,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solana Address',
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: const Color(0xffADB3BC),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.wallet.replaceRange(8, 36, '...'),
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
                const SizedBox(
                  height: 23,
                ),
                TextButton(
                  onPressed: () {
                    window.open(
                      'https://solscan.io/address/${widget.user.wallet}',
                      '_blank',
                    );
                  },
                  child: const Text(
                    'View your wallet on Solana blockchain >',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xffADB3BC),
                      color: Color(0xffADB3BC),
                      fontSize: 13.3,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 39,
                ),
                buildCurrencyBalance(
                  context,
                  userBalance.usdcBalance.uiAmount.toStringAsFixed(2),
                  'USDC',
                  'usdc_coin',
                  title: 'Receive USDC',
                  description:
                      'Send Solana USDC to this address to top-up your Subdoor balance',
                ),
                const SizedBox(
                  height: 33,
                ),
                buildCurrencyBalance(
                  context,
                  userBalance.nativeTokenBalance.uiAmount.toStringAsFixed(2),
                  'DPLN',
                  'dpln_coin',
                  title: 'Send DPLN tokens to add bids',
                  description:
                      'Send DPLN on Solana to this address to add bids',
                ),
                const SizedBox(
                  height: 33,
                ),
                buildCurrencyBalance(
                  context,
                  userBalance.bidBalance.toString(),
                  'BIDS',
                  'bids',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddBidsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
