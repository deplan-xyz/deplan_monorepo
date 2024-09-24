import 'package:deplan_subscriptions_client/api/common_api.dart';
import 'package:deplan_subscriptions_client/components/day_grid.dart';
import 'package:deplan_subscriptions_client/components/screen_wrapper.dart';
import 'package:deplan_subscriptions_client/components/subscription_card.dart';
import 'package:deplan_subscriptions_client/models/me.dart';
import 'package:deplan_subscriptions_client/models/subscription.dart';
import 'package:deplan_subscriptions_client/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionDetails extends StatefulWidget {
  final Subscription subscriptionData;
  final DateTime selectedDate;

  const SubscriptionDetails(
      {super.key, required this.subscriptionData, required this.selectedDate});

  @override
  State<SubscriptionDetails> createState() => _SubscriptionDetailsState();
}

class _SubscriptionDetailsState extends State<SubscriptionDetails> {
  late Future<UserResponse> meFuture;

  @override
  void initState() {
    super.initState();
    meFuture = api.getMe();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      showAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Image.network(
                widget.subscriptionData.logo!,
                width: 100,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.subscriptionData.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: Column(
        children: [
          SubscriptionCard(
            // month and year in format: January 2022
            title: DateFormat.yMMMM().format(widget.selectedDate),
            backgroundColor: const Color(0xffffffff),
            titleStyle: const TextStyle(
              fontSize: 30,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w700,
              color: TEXT_MAIN,
            ),
            planPrice: widget.subscriptionData.planPrice,
            userPays: widget.subscriptionData.youPay,
            orgId: widget.subscriptionData.orgId,
            usagePercentage: widget.subscriptionData.usage,
          ),
          FutureBuilder(
              future: meFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TextButton(
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        backgroundColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          color: TEXT_SECONDARY_ACCENT,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () {
                        final wallet = snapshot.data!.user.wallet;
                        launchUrl(
                            Uri.parse('https://solscan.io/address/$wallet'));
                      },
                      child: const Text('View on Chain'));
                }
                return const CupertinoActivityIndicator();
              }),
          Flexible(
            child: DayGrid(
              date: widget.selectedDate,
              subscriptionData: widget.subscriptionData,
            ),
          ),
        ],
      ),
    );
  }
}
