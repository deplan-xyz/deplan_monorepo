import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deplan/screens/login/create_profile_screen.dart';
import 'package:deplan/screens/login/install_pwa_android_screen.dart';
import 'package:deplan/screens/login/install_pwa_ios_screen.dart';
import 'package:deplan/screens/login/restore_account_screen.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/utils/platform.dart';
import 'package:deplan/widgets/buttons/secondary_button.dart';
import 'package:deplan/widgets/view/app_padding.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                flex: 2,
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
                      'Meet the new browser for the new internet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Make the Internet better. Together.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 18,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              child: const Text('Create Wallet'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      if (PlatformUtils.isWebAndroid()) {
                                        return const InstallPwaAndroidScreen();
                                      } else if (PlatformUtils.isWebIOS()) {
                                        return const InstallPwaIosScreen();
                                      }
                                      return const CreateProfileScreen();
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            SecondaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RestoreAccountScreen(),
                                  ),
                                );
                              },
                              child: const Text('Login via Secret Code'),
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
