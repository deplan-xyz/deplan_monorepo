import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/widgets/view/app_padding.dart';
import 'package:phorevr/widgets/view/screen_scaffold.dart';

class AccountSettingsSreen extends StatelessWidget {
  const AccountSettingsSreen({super.key});

  navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Settings',
      child: AppPadding(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  authApi.logout();
                  navigateToLogin(context);
                },
                icon: SvgPicture.asset('assets/icons/logout_icon.svg'),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: COLOR_RED,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
