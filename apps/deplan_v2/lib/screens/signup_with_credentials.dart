import 'dart:developer';

import 'package:deplan/api/auth.dart';
import 'package:deplan/components/custom_button.dart';
import 'package:deplan/components/custom_testfield.dart';
import 'package:deplan/components/ui_notifications.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/login_with_credentials.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:deplan/utilities/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupWithCredentialsScreen extends StatefulWidget {
  final SubscriptionQueryData? subscriptionQueryData;
  const SignupWithCredentialsScreen({super.key, this.subscriptionQueryData});

  @override
  State<SignupWithCredentialsScreen> createState() =>
      _SignupWithCredentialsScreenState();
}

class _SignupWithCredentialsScreenState
    extends State<SignupWithCredentialsScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _repeatPassword.dispose();
  }

  _signup(BuildContext context) async {
    if (!_validateInputs()) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      await Auth.signUpWithCredentials(_email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (context.mounted) {
        if (e.code == 'email-already-in-use') {
          showSnackBar(context, 'User already exists');
        } else {
          showSnackBar(context, 'Error signing up: ${e.code}');
        }
      }
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (context.mounted) {
      if (widget.subscriptionQueryData != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmSubsciption(
              subscriptionQueryData: widget.subscriptionQueryData!,
            ),
          ),
          (route) => false,
        );
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SubsciptionsHome()),
        (route) => false,
      );
    }
  }

  _validateInputs() {
    bool noEmptyFields = _email.text.isNotEmpty && _password.text.isNotEmpty;
    bool passwordsMatch = _password.text == _repeatPassword.text;
    bool validEmail = isValidEmail(_email.text);

    if (noEmptyFields && validEmail && passwordsMatch) {
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
    } else if (_repeatPassword.text.isEmpty) {
      showSnackBar(context, 'Repeat password is required');
      return false;
    } else if (_password.text != _repeatPassword.text) {
      showSnackBar(context, 'Passwords do not match');
      return false;
    } else {
      showSnackBar(context, 'Please enter both email and password');
      return false;
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
              'Signup to DePlan',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              hint: 'Enter Email',
              label: 'Email',
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Enter Password',
              label: 'Password',
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Repeat Password',
              label: 'Repeat Password',
              isPassword: true,
              controller: _repeatPassword,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'Signup',
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _signup(context);
                    },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginWithCredentialsScreen(
                          subscriptionQueryData: widget.subscriptionQueryData,
                        ),
                      ),
                    );
                  },
                  child:
                      const Text('Login', style: TextStyle(color: Colors.red)),
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
