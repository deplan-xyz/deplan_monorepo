import 'package:flutter/material.dart';
import 'package:deplan_v1/theme/app_theme.dart';

class IconButtonWithText extends StatelessWidget {
  final Widget image;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final double? buttonSize;
  final Function()? onPressed;

  const IconButtonWithText({
    super.key,
    required this.image,
    required this.text,
    this.textColor,
    this.onPressed,
    this.backgroundColor,
    this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: buttonSize ?? 40,
              width: buttonSize ?? 40,
              decoration: BoxDecoration(
                color: backgroundColor ?? COLOR_WHITE,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: image,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor ?? COLOR_ALMOST_BLACK,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
