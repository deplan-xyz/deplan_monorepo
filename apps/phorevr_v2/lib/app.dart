import 'package:flutter/material.dart';
import 'package:phorevr/app_home.dart';
import 'package:phorevr/screens/subscribe_screen.dart';
import 'package:phorevr/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phorevr',
      theme: getAppTheme(),
      routes: {
        AppHome.routeName: (context) => const AppHome(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith(SubscribeScreen.routeName)) {
          return MaterialPageRoute(
            builder: (_) => const SubscribeScreen(),
          );
        }
        return null;
      },
    );
  }
}
