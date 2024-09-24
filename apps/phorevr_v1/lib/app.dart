import 'package:flutter/material.dart';
import 'package:phorevr_v1/app_home.dart';
import 'package:phorevr_v1/theme/app_theme.dart';

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
    );
  }
}
