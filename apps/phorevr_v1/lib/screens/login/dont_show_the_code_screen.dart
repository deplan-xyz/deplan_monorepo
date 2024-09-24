import 'package:flutter/material.dart';
import 'package:phorevr_v1/screens/login/check_login_code_screen.dart';
import 'package:phorevr_v1/widgets/view/screen_scaffold.dart';

class DontShowTheCodeScreen extends StatelessWidget {
  final String code;

  const DontShowTheCodeScreen({Key? key, required this.code}) : super(key: key);

  handleNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CheckLoginCodeScreen(
            code: code,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      fontSize: 18,
      color: Color(0xFFBB3A79),
      fontWeight: FontWeight.w700,
    );

    return ScreenScaffold(
      title: 'Don’t Show the Code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 80),
          const Text(
            "Don't show the Code to Your'\nAccount to anyone else.",
            style: textStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          const Text(
            "Don't send the Code to Your\nAccount to anyone else.",
            style: textStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: textStyle,
              children: [
                TextSpan(
                  text: "Don't put this code to any\nwebsites except\n",
                ),
                TextSpan(
                  text: 'app.phorevr.com',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 45),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 270,
              child: ElevatedButton(
                onPressed: () => handleNext(context),
                child: const Text(
                  'Got it. Continue.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
