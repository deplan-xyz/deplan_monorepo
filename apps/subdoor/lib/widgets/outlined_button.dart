import 'package:flutter/material.dart';

class OutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const OutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
      ),
      child: child,
    );
  }
}
