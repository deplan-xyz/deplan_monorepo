import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deplan/screens/login/create_profile_screen.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/widgets/view/app_padding.dart';
import 'package:deplan/widgets/view/screen_scaffold.dart';

class InstallPwaIosScreen extends StatelessWidget {
  const InstallPwaIosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Install deplan as an App',
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
                          WidgetSpan(
                            child: Icon(
                              CupertinoIcons.share,
                              color: COLOR_BLUE,
                            ),
                          ),
                          TextSpan(
                            text: 'Share ',
                            style: TextStyle(
                              color: COLOR_BLUE,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                'button on the bottom panel of the browser. Then select ',
                          ),
                          TextSpan(
                            text: 'Add to Home Screen',
                            style: TextStyle(
                              color: COLOR_BLUE,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Image.asset('assets/images/ios_pwa.png'),
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
                      builder: (_) => const CreateProfileScreen(),
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
