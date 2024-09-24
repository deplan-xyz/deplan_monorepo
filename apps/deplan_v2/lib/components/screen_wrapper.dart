import 'package:flutter/material.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final bool showAppBar;
  final String title;
  final bool showBackButton;

  const ScreenWrapper({
    super.key,
    this.child = const SizedBox(),
    this.showAppBar = false,
    this.title = '',
    this.showBackButton = false,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? appBar as PreferredSizeWidget? : null,
      body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 20, 20, 20), child: child,),
    );
  }
}
