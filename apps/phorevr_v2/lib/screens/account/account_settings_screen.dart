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

  handleDeleteAccountPressed(BuildContext context) async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(
            'Are you sure you want to delete your account permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: COLOR_RED,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) {
      return;
    }
    await authApi.deleteAccount();
    if (context.mounted) {
      navigateToLogin(context);
    }
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
                onPressed: () => handleDeleteAccountPressed(context),
                icon: const Icon(
                  Icons.person_remove_alt_1,
                  color: COLOR_RED,
                ),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: COLOR_RED,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
