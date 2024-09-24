import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future shouwAuthErrorDialog({
  required BuildContext context,
  required FirebaseAuthException error,
}) async {
  // set up the buttons
  final Widget okButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    onPressed: () => Navigator.pop(context, 'ok'),
    child: const Text('Ok'),
  );

  final alert = AlertDialog(
    backgroundColor: Colors.white,
    iconColor: Colors.red,
    contentTextStyle: const TextStyle(color: Colors.black),
    icon: const Icon(Icons.error),
    title: const Text('Authentication error'),
    content: Text(getFirebaseErrorPrettifiedText(error)),
    actions: [
      okButton,
    ],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.white),
    ),
  );

  // show the dialog
  return showDialog(
    context: context,
    builder: (context) => alert,
  );
}

String getFirebaseErrorPrettifiedText(FirebaseAuthException? error) {
  if (error == null) {
    return 'An error occurred.';
  }
  switch (error.code) {
    case 'invalid-credential':
      return 'The credential is malformed or has expired.';
    case 'user-disabled':
      return 'The user has been disabled.';
    case 'user-not-found':
      return 'The user does not exist.';
    case 'popup-closed-by-user':
      return 'The authentication popup was closed by the user.\nPlease refresh the page and try again.';
    default:
      return 'An error occurred.';
  }
}
