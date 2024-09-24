import 'package:flutter/material.dart';
import 'package:deplan_v1/theme/app_theme.dart';

class SecondaryButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final Color foregroundColor;

  const SecondaryButton({
    Key? key,
    this.child,
    required this.onPressed,
    this.foregroundColor = COLOR_ALMOST_BLACK,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(
          color: foregroundColor,
        ),
        foregroundColor: foregroundColor,
      ),
      child: child,
    );
  }
}
