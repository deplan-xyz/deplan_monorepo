import 'package:subdoor/pages/storybook_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:subdoor/app_home.dart';
import 'package:subdoor/theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subdoor — Subscribe with crypto',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      routes: {
        '/': (context) => const AppHome(),
        '/storybook': (context) => const StorybookScreen(),
      },
    );
  }
}
