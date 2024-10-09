import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:deplan/api/auth.dart';
import 'package:deplan/api/base_api.dart';
import 'dart:convert';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/screens/confirm_subsciption.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:deplan_core/utils/deplan_utils.dart'
    if (dart.library.js_interop) 'dart:html' show window;

class AppleSignInButton extends StatelessWidget {
  final SubscriptionQueryData? subscriptionQueryData;
  const AppleSignInButton({super.key, this.subscriptionQueryData});

  @override
  Widget build(BuildContext context) {
    navigateToSubscriptionsHome(SubscriptionQueryData? subscriptionQueryData) {
      if (subscriptionQueryData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmSubsciption(
              subscriptionQueryData: subscriptionQueryData,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SubsciptionsHome(),
          ),
        );
      }
    }

    return SignInWithAppleButton(
      onPressed: () async {
        String rawNonce = generateNonce();
        String hashSHA256String = createHashSHA256String(rawNonce);
        final redirectUrl = kIsWeb
            ? 'https://${window.location.host}'
            : 'https://$baseUrl/auth/signin/apple/callback';
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'com.deplan.dev',
            redirectUri: Uri.parse(redirectUrl),
          ),
          nonce: hashSHA256String,
          state: 'deplan-state',
        );

        String idToken = credential.identityToken!;

        final fullName = AppleFullPersonName(
          familyName: 'Name',
          givenName: 'Your',
        );
        final credentials = AppleAuthProvider.credentialWithIDToken(
          idToken,
          rawNonce,
          fullName,
        );

        await Auth.signInWithApple(credentials);
        navigateToSubscriptionsHome(subscriptionQueryData);
      },
    );
  }
}

String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

String createHashSHA256String(String rawNonce) {
  final bytes = utf8.encode(rawNonce);
  final hash = sha256.convert(bytes);
  return hash.toString();
}
