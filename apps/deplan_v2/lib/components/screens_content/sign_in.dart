import 'package:deplan_subscriptions_client/components/apple_sign_in_button.dart';
import 'package:deplan_subscriptions_client/models/subscription_query_data.dart';
import 'package:deplan_subscriptions_client/screens/login_with_credentials.dart';
import 'package:deplan_subscriptions_client/screens/signup_with_credentials.dart';
import 'package:deplan_subscriptions_client/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum Mode { signUp, signIn }

class SignInBody extends StatelessWidget {
  final SubscriptionQueryData? subscriptionQueryData;
  const SignInBody({super.key, this.subscriptionQueryData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Image.asset('assets/images/DePlan_Logo Blue.png'),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(child: Image.asset('assets/images/subsription-logo.png')),
        const SizedBox(height: 30),
        Text(
          "Pay for how much you actually use your subscriptions",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Control all your subscriptions in one place",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SF Pro Display',
                  color: TEXT_SECONDARY,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 52,
                child: AppleSignInButton(
                    subscriptionQueryData: subscriptionQueryData),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 52,
                child: EnterWithCredentialsButton(
                  mode: Mode.signIn,
                  subscriptionQueryData: subscriptionQueryData,
                ),
              ),
              const SizedBox(width: 10),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class EnterWithCredentialsButton extends StatelessWidget {
  final Mode mode;
  final SubscriptionQueryData? subscriptionQueryData;

  const EnterWithCredentialsButton(
      {super.key, required this.mode, this.subscriptionQueryData});

  @override
  Widget build(BuildContext context) {
    final signUpButton = TextButton(
      child: const Text('Register using email'),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupWithCredentialsScreen(
              subscriptionQueryData: subscriptionQueryData,
            ),
          ),
        );
      },
    );

    final signInButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MAIN_COLOR,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginWithCredentialsScreen(
              subscriptionQueryData: subscriptionQueryData,
            ),
          ),
        );
      },
      child: const Text('Continue with email'),
    );

    return mode == Mode.signUp ? signUpButton : signInButton;
  }
}
