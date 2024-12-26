import 'dart:io';

import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/pages/login/login_basic_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:deplan_core/utils/deplan_utils.dart'
    if (dart.library.js_interop) 'dart:html' show window;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
          : '${authApi.baseUrl}/subdoor/auth/signin/apple/callback';
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.subdoor.dev',
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
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Logo + Title
          Image.asset(
            'assets/images/logo_with_text.png',
            width: 258,
          ),
          const Text(
            'Subscribe to your favorite\nproducts with crypto.\n\nEven if they don\'t accept crypto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'sfprod',
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 340,
                  child: ElevatedButton(
                    onPressed: () {
                      loginWithApple(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                      backgroundColor: const Color(0xff020203),
                      foregroundColor: const Color(0xffFFFFFF),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/apple.png',
                          width: 19,
                        ),
                        const Expanded(child: SizedBox()),
                        const Text('Continue with Apple'),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 340,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginUsernameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                      side: const BorderSide(
                        color: primaryColor,
                      ),
                      foregroundColor: primaryColor,
                      backgroundColor: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person, color: primaryColor),
                        Expanded(child: SizedBox()),
                        Text('Continue with Email'),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
