import 'package:flutter/material.dart';

enum SnackBarType {
  error,
  success,
  info,
  warning,
}

showSnackBar(BuildContext context, String message,
    {SnackBarType type = SnackBarType.error,}) {
  Color color;
  switch (type) {
    case SnackBarType.error:
      color = Colors.red;
      break;
    case SnackBarType.success:
      color = Colors.green;
      break;
    case SnackBarType.info:
      color = Colors.blue;
      break;
    case SnackBarType.warning:
      color = Colors.orange;
      break;
    default:
      color = Colors.red;
      break;
  }

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(message),
    ),
  );
}
