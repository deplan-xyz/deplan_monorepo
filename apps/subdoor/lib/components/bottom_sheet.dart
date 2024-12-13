import 'package:flutter/material.dart';

Future<bool?> showAppBottomSheet(
  BuildContext context,
  Widget Function(BuildContext) builder, {
  Color backgroundColor = Colors.white,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Wrap(
        children: [
          builder(context),
        ],
      ),
    ),
  );
}
