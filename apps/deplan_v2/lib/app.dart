import 'dart:async';
import 'package:deplan_subscriptions_client/models/subscription.dart';
import 'package:deplan_subscriptions_client/models/subscription_query_data.dart';
import 'package:deplan_subscriptions_client/screens/app_init_controller.dart';
import 'package:deplan_subscriptions_client/screens/settings_screen.dart';
import 'package:deplan_subscriptions_client/screens/subsciptions_home.dart';
import 'package:deplan_subscriptions_client/screens/subscription_details.dart';
import 'package:deplan_subscriptions_client/utilities/uri.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deplan_subscriptions_client/screens/confirm_subsciption.dart';
import 'package:deplan_subscriptions_client/screens/signin.dart';
import 'package:deplan_subscriptions_client/theme/app_theme.dart';
import 'package:deplan_subscriptions_client/constants/routes.dart';
import 'package:uni_links/uni_links.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  FirebaseAuth get auth => FirebaseAuth.instance;
  StreamSubscription? _sub;
  // naviation key
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _navigateToConfirmSubscription(String orgId) {
    _navigatorKey.currentState!.pushNamed(
      Routes.confirmSubscription,
      arguments: orgId,
    );
  }

  void _handleIncomingLinks() async {
    // Handle deep link when the app is already running (iOS only)
    _sub = uriLinkStream.listen((Uri? uri) {
      final orgId = getOrgIdFromUri(uri);
      if (orgId != null) {
        _navigateToConfirmSubscription(orgId);
      }
    }, onError: (err) {
      // Handle error
      print('Error: $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'DePlan',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      initialRoute: Routes.appInitController,
      routes: {
        Routes.appInitController: (context) => const AppInitController(),
        Routes.signin: (context) => const Signin(),
        Routes.subscriptionsHome: (context) => const SubsciptionsHome(),
        Routes.settings: (context) => const SettingsScreen(),
        Routes.confirmSubscription: (context) => ConfirmSubsciption(
              subscriptionQueryData: SubscriptionQueryData(
                orgId: 'default',
                redirectUrl: 'default',
                data: 'default',
              ),
            ),
        Routes.subscriptionDetails: (context) => SubscriptionDetails(
              subscriptionData:
                  ModalRoute.of(context)!.settings.arguments as Subscription,
              selectedDate: DateTime.now(),
            ),
      },
    );
  }
}
