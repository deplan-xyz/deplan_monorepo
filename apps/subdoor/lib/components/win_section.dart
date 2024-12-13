import 'package:subdoor/components/pay_button.dart';
import 'package:subdoor/components/pay_timer.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/pages/subscription_access_screen.dart';
import 'package:flutter/material.dart';

class WinSection extends StatelessWidget {
  final UserBalance balance;
  final AuctionItem auctionItem;

  const WinSection({
    super.key,
    required this.balance,
    required this.auctionItem,
  });

  void navigateSubscriptionAccess(BuildContext context, AuctionItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionAccessScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'You won ${auctionItem.discountPercent.toStringAsFixed(0)}%\ndiscount!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'sfprodbold',
            fontSize: 36,
            height: 1.1,
            color: Color(0xff000000),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'sfprodbold',
              fontSize: 24,
              height: 1.1,
              color: Color(0xff000000),
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: 'Pay \$${auctionItem.currentPrice} instead of'),
              TextSpan(
                text: ' \$${auctionItem.originalPrice}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ),
        Text(
          'and get ${auctionItem.name} subscription',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'sfprodbold',
            fontSize: 20,
            color: Color(0xff828C9A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 60,
        ),
        // Pay Button
        SizedBox(
          width: 290,
          child: PayButton(
            item: auctionItem,
            onPaid: (item) => navigateSubscriptionAccess(context, item),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Your current USDC balance \$${balance.usdcBalance.uiAmount.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xff828C9A),
            fontFamily: 'sfprod',
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        PayTimer(
          item: auctionItem,
        ),
      ],
    );
  }
}
