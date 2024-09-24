import 'package:deplan_subscriptions_client/components/screen_wrapper.dart';
import 'package:deplan_subscriptions_client/components/screens_content/sign_in.dart';
import 'package:deplan_subscriptions_client/models/subscription_query_data.dart';
import 'package:flutter/material.dart';

class Signin extends StatelessWidget {
  final SubscriptionQueryData? subscriptionQueryData;
  const Signin({super.key, this.subscriptionQueryData});

  @override
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: SignInBody(subscriptionQueryData: subscriptionQueryData),
    );
  }
}
