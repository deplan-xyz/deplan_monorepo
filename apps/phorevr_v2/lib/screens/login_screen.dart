import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/screens/home_screen.dart';
import 'package:phorevr/screens/login/login_email_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/widgets/view/app_padding.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:deplan_core/deplan_core.dart'
    if (dart.library.js_interop) 'dart:html' show window;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  loginWithApple(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      final redirectUrl = kIsWeb
          ? 'https://${window.location.host}'
          : 'https://${authApi.baseUrl}/phorevr/auth/signin/apple/callback';
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.phorevr.dev',
          redirectUri: Uri.parse(redirectUrl),
        ),
        state: 'state',
        nonce: 'nonce',
      );
      final useBundleId = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
      await authApi.signinApple(
        credential.authorizationCode,
        useBundleId,
        redirectUrl,
      );
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (_) => false,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        _displayError(e.response!.data['message']);
      } else {
        _displayError('Login failed. Please try again.');
      }
    } catch (e) {
      print(e);
      _displayError('Login failed. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String logoPath = 'assets/images/logo_with_text.png';
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: AppPadding(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        logoPath,
                        width: 250,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'The first Pay-As-You-Go\nphoto storage ever.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'Store forever. Pay while using.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (kIsWeb || Platform.isIOS || Platform.isMacOS)
                              ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => loginWithApple(context),
                                child: const Text('Continue with Apple'),
                              ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginEmailScreen(),
                                  ),
                                );
                              },
                              style:
                                  kIsWeb || Platform.isIOS || Platform.isMacOS
                                      ? ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          side: const BorderSide(
                                            color: COLOR_ALMOST_BLACK,
                                          ),
                                          foregroundColor: COLOR_ALMOST_BLACK,
                                        )
                                      : null,
                              child: const Text('Continue with Email'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
