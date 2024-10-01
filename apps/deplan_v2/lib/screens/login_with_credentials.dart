import 'package:deplan/api/auth.dart';
import 'package:deplan/components/custom_button.dart';
import 'package:deplan/components/custom_testfield.dart';
import 'package:deplan/components/ui_notifications.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/signup_with_credentials.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:deplan/utilities/validators.dart';
import 'package:flutter/material.dart';

class LoginWithCredentialsScreen extends StatefulWidget {
  final SubscriptionQueryData? subscriptionQueryData;

  const LoginWithCredentialsScreen({super.key, this.subscriptionQueryData});

  @override
  State<LoginWithCredentialsScreen> createState() =>
      _LoginWithCredentialsScreenState();
}

class _LoginWithCredentialsScreenState
    extends State<LoginWithCredentialsScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  _validateInputs() {
    bool noEmptyFields = _email.text.isNotEmpty && _password.text.isNotEmpty;
    bool validEmail = isValidEmail(_email.text);

    if (noEmptyFields && validEmail) {
      setState(() {
        isLoading = true;
      });
      return true;
    } else if (_email.text.isEmpty) {
      showSnackBar(context, 'Email is required');
      return false;
    } else if (!validEmail) {
      showSnackBar(context, 'Please enter a valid email');
      return false;
    } else if (_password.text.isEmpty) {
      showSnackBar(context, 'Password is required');
      return false;
    } else {
      showSnackBar(context, 'Please enter both email and password');
      return false;
    }
  }

  _loginWithCredentials(BuildContext context) async {
    if (!_validateInputs()) {
      return;
    }

    try {
      final user =
          await Auth.signInWithCredentials(_email.text, _password.text);

      if (widget.subscriptionQueryData != null && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmSubsciption(
              subscriptionQueryData: widget.subscriptionQueryData!,
            ),
          ),
          (route) => false,
        );

        return;
      }

      if (user != null && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const SubsciptionsHome(),
          ),
          (route) => false,
        );
      } else if (context.mounted) {
        showSnackBar(context, 'User not found');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Credentials are invalid or user not found');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Login to DePlan',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            CustomTextField(
              hint: 'Enter Email',
              label: 'Email',
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              isPassword: true,
              hint: 'Enter Password',
              label: 'Password',
              controller: _password,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'Login',
              onPressed: isLoading
                  ? null
                  : () async {
                      await _loginWithCredentials(context);
                    },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupWithCredentialsScreen(
                          subscriptionQueryData: widget.subscriptionQueryData,
                        ),
                      ),
                    );
                  },
                  child:
                      const Text('Signup', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
