import 'dart:io';

import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/wallet/abstract/wallet_provider_registry.dart';
import 'package:subdoor/wallet/types/wallet_provider.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/pages/login/login_basic_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/wallet/abstract/factory.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deplan_core/utils/deplan_utils.dart'
    if (dart.library.js_interop) 'dart:html' show window;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late WalletFactory walletFactory;
  late WalletProviderRegistry walletProviderRegistry;

  WalletProvider? phantomProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    walletFactory = context.read<WalletFactory>();
    walletProviderRegistry = walletFactory.createWalletProviderRegistry();
    phantomProvider = walletProviderRegistry.solanaProviders.firstWhereOrNull(
      (provider) => provider.name == 'Phantom',
    );
  }

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

  buildButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderSide? borderSide,
  }) {
    return SizedBox(
      width: 340,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: borderSide,
        ),
        child: Row(
          children: [
            icon,
            const Expanded(child: SizedBox()),
            Text(text),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  loginWithSolana(BuildContext context, String walletName) async {
    final wallet = walletFactory.createSolanaWallet();
    final result = await wallet.signIn(walletName);

    setState(() {
      isLoading = true;
    });

    try {
      await authApi.signinSolana(
        wallet,
        result.signature,
        result.message,
        result.address,
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

  Color getProviderColor(WalletProvider provider) {
    switch (provider.name) {
      case 'Phantom':
        return const Color(0xffAB9FF2);
      default:
        return primaryColor;
    }
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
                child: buildButton(
                  icon: Image.asset(
                    'assets/images/apple.png',
                    width: 19,
                  ),
                  text: 'Continue with Apple',
                  onPressed: () {
                    loginWithApple(context);
                  },
                  backgroundColor: const Color(0xff020203),
                  foregroundColor: const Color(0xffFFFFFF),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: buildButton(
                  icon: const Icon(Icons.person, color: primaryColor),
                  text: 'Continue with Email',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginUsernameScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  borderSide: const BorderSide(
                    color: primaryColor,
                  ),
                ),
              ),
              if (phantomProvider != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    buildButton(
                      icon: SvgPicture.memory(
                        phantomProvider!.iconBytes!,
                        width: 25,
                      ),
                      text: 'Connect ${phantomProvider!.name} Wallet',
                      backgroundColor: getProviderColor(phantomProvider!),
                      foregroundColor: Colors.white,
                      onPressed: () {
                        loginWithSolana(context, phantomProvider!.name);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
