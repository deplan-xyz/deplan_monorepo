import 'package:flutter/material.dart';
import 'package:phorevr_v1/api/auth_api.dart';
import 'package:phorevr_v1/screens/login/create_profile_screen.dart';
import 'package:phorevr_v1/theme/app_theme.dart';
import 'package:phorevr_v1/widgets/view/app_padding.dart';
import 'package:phorevr_v1/widgets/view/screen_scaffold.dart';

class InstallPwaAndroidScreen extends StatelessWidget {
  const InstallPwaAndroidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Install Phorevr as an App',
      child: AppPadding(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 4,
                            color: COLOR_LIGHT_GRAY2,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/app_icon.jpeg'),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: COLOR_GRAY, height: 1.5),
                        children: const [
                          TextSpan(
                            text: 'Click on the ',
                          ),
                          TextSpan(
                            text: 'Three dots ',
                            style: TextStyle(
                              color: COLOR_BLUE,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'in the corner of the browser. Select ',
                          ),
                          TextSpan(
                            text: 'Install App ',
                            style: TextStyle(
                              color: COLOR_BLUE,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'in the menu that opens. Click on the ',
                          ),
                          TextSpan(
                            text: 'Install ',
                            style: TextStyle(
                              color: COLOR_BLUE,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                'button in the window that opens. Find the Phorevr icon on your Home Screen.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Image.asset('assets/images/android_pwa.png'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 290,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateProfileScreen(
                        dePlanSignInData: DePlanSignInData(),
                      ),
                    ),
                  );
                },
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
