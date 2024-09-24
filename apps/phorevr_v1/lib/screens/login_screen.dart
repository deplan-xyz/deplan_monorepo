import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/screens/home_screen.dart';
import 'package:phorevr/screens/login/create_profile_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/utils/js_deplan.dart' as deplan;
import 'package:phorevr/widgets/view/app_padding.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  loginWithDePlan(BuildContext context) async {
    final deplanRes = await deplan.signIn();
    final deplanSignInData = DePlanSignInData(
      wallet: deplanRes['address'],
      signInMsg: deplanRes['message'],
      signature: deplanRes['signature'],
    );
    try {
      await authApi.signinDeplan(deplanSignInData);
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (_) => false,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateProfileScreen(
              dePlanSignInData: deplanSignInData,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
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
                    const SizedBox(height: 100),
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
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: COLOR_ALMOST_BLACK),
                      ),
                      child: const Text(
                        '\$0.10 / hour',
                        style: TextStyle(
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
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
                            ElevatedButton(
                              onPressed: () => loginWithDePlan(context),
                              child: const Text('Use with Pay-As-You-Go'),
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
