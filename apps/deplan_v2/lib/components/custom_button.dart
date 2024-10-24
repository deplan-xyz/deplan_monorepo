import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final VisualDensity? visualDensity;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.visualDensity,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MAIN_COLOR,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        visualDensity: visualDensity,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
