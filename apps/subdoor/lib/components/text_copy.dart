import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void _callSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Copied to clipboard'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void copyText(BuildContext context, String text) async {
  Clipboard.setData(ClipboardData(text: text));
  _callSnackBar(context);
}
