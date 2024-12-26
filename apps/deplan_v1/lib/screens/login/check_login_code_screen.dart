import 'package:deplan_core/deplan_core.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deplan_v1/screens/home_screen.dart';
import 'package:deplan_v1/widgets/form/input_form.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';

class CheckLoginCodeScreen extends StatefulWidget {
  final String code;

  const CheckLoginCodeScreen({Key? key, required this.code}) : super(key: key);

  @override
  State<CheckLoginCodeScreen> createState() => _CheckLoginCodeScreen();
}

class _CheckLoginCodeScreen extends State<CheckLoginCodeScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String get code => widget.code;
  bool? codesMatch;

  handleNext() {
    if (!formKey.currentState!.validate() ||
        codesMatch == null ||
        !codesMatch!) {
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
      (route) => false,
    );
  }

  getValidationStatusText() {
    if (codesMatch == null) {
      return 'Paste the code to make sure you have copied it.';
    }
    if (codesMatch == true) {
      return 'The code is valid';
    }
    return 'The code is not valid';
  }

  getValidationStatusIcon() {
    if (codesMatch == true) {
      return 'assets/icons/check_filled.svg';
    }
    return 'assets/icons/cross_red.svg';
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Check the Code to your Account',
      child: KeyboardDismissableListView(
        children: [
          AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 80),
                const Text(
                  'Paste the code to make\nsure you have copied it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 50),
                InputForm(
                  formKey: formKey,
                  child: AppTextFormFieldBordered(
                    maxLines: 8,
                    minLines: 8,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        codesMatch = value == code;
                      });
                    },
                    validator: requiredField('Code'),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getValidationStatusText(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF87899B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    codesMatch != null
                        ? SvgPicture.asset(getValidationStatusIcon())
                        : Container(),
                  ],
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 240,
                    child: ElevatedButton(
                      onPressed: handleNext,
                      child: const Text('Finish Creating Account '),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Be sure you save the code.\nYou won’t be able to get\naccess to your account\nwithout this code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBB3A79),
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
