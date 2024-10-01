import 'package:deplan/api/auth.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/signin.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppInitController extends StatefulWidget {
  const AppInitController({super.key});

  @override
  State<AppInitController> createState() => _AppInitControllerState();
}

class _AppInitControllerState extends State<AppInitController> {
  @override
  void initState() {
    super.initState();
  }

  Future<SubscriptionQueryData?> _handleQueryParameters(
    BuildContext ctx,
  ) async {
    Future.delayed(const Duration(milliseconds: 200));
    final Uri uri = Uri.base;

    final Map<String, String> queryParams = uri.queryParameters;

    String? orgId = queryParams['orgId'];
    String? redirectUrl = queryParams['redirectUrl'];
    String? data = queryParams['data'];

    if (data != null && orgId != null && redirectUrl != null) {
      return SubscriptionQueryData(
          orgId: orgId, redirectUrl: redirectUrl, data: data);
    }

    return null;
  }

  _handleInitialNavigation(SubscriptionQueryData? subscriptionQueryData) {
    final isAuthenticated = Auth.isUserAuthenticated;
    final hasQueryParams = subscriptionQueryData != null;

    if (isAuthenticated && hasQueryParams) {
      return ConfirmSubsciption(subscriptionQueryData: subscriptionQueryData);
    } else if (isAuthenticated && !hasQueryParams) {
      return const SubsciptionsHome();
    } else if (!isAuthenticated) {
      return Signin(subscriptionQueryData: subscriptionQueryData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _handleQueryParameters(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          }
          return _handleInitialNavigation(snapshot.data);
        },
      ),
    );
  }
}
