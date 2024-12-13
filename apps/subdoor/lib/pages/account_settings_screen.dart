import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/material.dart';

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
                foregroundColor: Colors.red,
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BodyPadding(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => handleDeleteAccountPressed(context),
                icon: const Icon(
                  Icons.person_remove_alt_1,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
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
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
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
