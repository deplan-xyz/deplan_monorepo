import 'package:flutter/material.dart';

class KeyboardDismissableListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const KeyboardDismissableListView({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding,
      children: children,
    );
  }
}
