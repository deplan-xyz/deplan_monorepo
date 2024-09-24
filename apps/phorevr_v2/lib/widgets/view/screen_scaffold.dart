import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phorevr/theme/app_theme.dart';

class ScreenScaffold extends StatelessWidget {
  final Widget child;
  final dynamic title;
  final List<Widget>? actions;
  final Widget? leading;

  const ScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: title is String ? Text(title) : title,
        actions: actions,
        leading: leading,
        leadingWidth: 70,
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
