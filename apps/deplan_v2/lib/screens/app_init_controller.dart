import 'package:deplan/api/auth.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/signin.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:flutter/cupertino.dart';

class AppInitController extends StatefulWidget {
  const AppInitController({super.key});

  @override
  State<AppInitController> createState() => _AppInitControllerState();
}

class _AppInitControllerState extends State<AppInitController> {
  bool? hasQueryParams;
  String? orgId;
  String? redirectUrl;
  String? data;

  @override
  void initState() {
    super.initState();
    _handleQueryParameters(context);
  }

  void _handleQueryParameters(BuildContext ctx) {
    if (!ctx.mounted) {
      return;
    }
    final Uri uri = Uri.base;

    final Map<String, String> queryParams = uri.queryParameters;

    String? orgId = queryParams['orgId'];
    String? redirectUrl = queryParams['redirectUrl'];
    String? data = queryParams['data'];

    if (data != null && orgId != null && redirectUrl != null) {
      setState(() {
        hasQueryParams = true;
        this.orgId = orgId;
        this.redirectUrl = redirectUrl;
        this.data = data;
      });
    } else {
      setState(() {
        hasQueryParams = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Auth.isUserAuthenticated;

    if (isAuthenticated && hasQueryParams == true) {
      final subscriptionQueryData = SubscriptionQueryData(
          orgId: orgId!, redirectUrl: redirectUrl!, data: data!,);
      return ConfirmSubsciption(subscriptionQueryData: subscriptionQueryData);
    }

    if (isAuthenticated && hasQueryParams == false) {
      return const SubsciptionsHome();
    }

    if (!isAuthenticated) {
      final subscriptionQueryData = hasQueryParams == true
          ? SubscriptionQueryData(
              orgId: orgId!, redirectUrl: redirectUrl!, data: data!,)
          : null;
      return Signin(subscriptionQueryData: subscriptionQueryData);
    }

    return const ScreenWrapper(
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}
