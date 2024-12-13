import 'dart:async';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/app_init_controller.dart';
import 'package:deplan/screens/settings_screen.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:deplan/screens/subscription_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/signin.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/constants/routes.dart';

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
        Routes.signin: (context) => const Signin(),
      },
    );
  }
}
