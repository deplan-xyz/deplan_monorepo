import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/day_grid.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/components/subscription_card.dart';
import 'package:deplan/models/me.dart';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionDetails extends StatefulWidget {
  final Subscription subscriptionData;
  final DateTime selectedDate;

  const SubscriptionDetails({
    super.key,
    required this.subscriptionData,
    required this.selectedDate,
  });

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
        title: Row(
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
                      Uri.parse('https://solscan.io/address/$wallet'),
                    );
                  },
                  child: const Text('Check usage on blockchain'),
                );
              }
              return const CupertinoActivityIndicator();
            },
          ),
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
