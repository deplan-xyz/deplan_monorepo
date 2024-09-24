import 'package:app_version_update/data/models/app_version_result.dart';
import 'package:deplan_v1/constants.dart';
import 'package:deplan_v1/services/app_link_service.dart';
import 'package:deplan_v1/screens/update_screen.dart';
import 'package:deplan_v1/services/navigator_service.dart';
import 'package:deplan_v1/widgets/web3/wallet_connect.dart';
import 'package:flutter/material.dart';
import 'package:deplan_v1/app_home.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:app_version_update/app_version_update.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<AppLinkService> futureAppLinkService;
  late Future<AppVersionResult> futureAppVersion;

  @override
  void initState() {
    super.initState();
    futureAppLinkService = AppLinkService().init();
    futureAppVersion = checkForUpdates();
  }

  checkForUpdates() {
    return AppVersionUpdate.checkForUpdates(
      appleId: APP_STORE_ID,
      playStoreId: ANDROID_APP_BUNDLE_ID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'DePlan',
      theme: getAppTheme(),
      initialRoute: AppHome.routeName,
      routes: {
        AppHome.routeName: (context) => const AppHome(),
      },
      builder: (context, child) {
        return FutureBuilder(
          future: Future.wait([
            futureAppLinkService,
            futureAppVersion,
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final appLinkService = snapshot.data![0] as AppLinkService;
            final appVersion = snapshot.data![1] as AppVersionResult;
            if (appVersion.canUpdate!) {
              return const UpdateScreen();
            }
            return ProxyProvider0(
              update: (_, __) => appLinkService,
              child: Column(
                children: [
                  Expanded(child: child!),
                  const WalletConnect(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
