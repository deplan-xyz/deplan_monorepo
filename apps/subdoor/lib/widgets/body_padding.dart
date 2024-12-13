import 'package:flutter/material.dart';

class BodyPadding extends StatelessWidget {
  final Widget child;
  final double? verticalPadding;

  const BodyPadding({super.key, required this.child, this.verticalPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 28,
        vertical: verticalPadding ?? 0,
      ),
      child: child,
    );
  }
}
