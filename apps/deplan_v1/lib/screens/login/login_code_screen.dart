import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deplan/screens/login/dont_show_the_code_screen.dart';
import 'package:deplan/widgets/buttons/secondary_button.dart';
import 'package:deplan/widgets/form/input_form.dart';
import 'package:deplan/widgets/view/app_padding.dart';
import 'package:deplan/widgets/view/screen_scaffold.dart';

class LoginCodeScreen extends StatefulWidget {
  final String code;

  const LoginCodeScreen({Key? key, required this.code}) : super(key: key);

  @override
  State<LoginCodeScreen> createState() => _LoginCodeScreen();
}

class _LoginCodeScreen extends State<LoginCodeScreen> {
  String get code => widget.code;
  bool _copied = false;

  handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DontShowTheCodeScreen(
            code: code,
          );
        },
      ),
    );
  }

  callSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Code is your login',
      child: ListView(
        children: [
          AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'This unique code is a login to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFBB3A79),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFBB3A79),
                      fontWeight: FontWeight.w700,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Please, ',
                      ),
                      TextSpan(
                        text: 'copy the code and save it in the safe place ',
                        style: TextStyle(color: Color(0xFF000000)),
                      ),
                      TextSpan(
                        text: 'to be able to log in to your account.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextFormFieldBordered(
                  enabled: false,
                  readOnly: true,
                  minLines: 8,
                  maxLines: 8,
                  controller: TextEditingController(text: code),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 290,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SecondaryButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          callSnackBar(context);
                          setState(() {
                            _copied = true;
                          });
                        },
                        child: const Text(
                          'Copy the Code',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _copied ? handleNext : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
