import 'package:deplan/api/auth.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/screens/change_password.dart';
import 'package:deplan/screens/signin.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  _navigateToSignin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Signin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      showAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.person_2_outlined,
                      color: MAIN_COLOR,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TEXT_MAIN,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      Auth.currentUser?.email ?? '',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16, color: COLOR_GRAY),
                    ),
                  ],
                ),
                const Divider(
                  color: COLOR_GRAY2,
                  height: 20,
                  thickness: 1,
                  endIndent: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: TEXT_MAIN,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Change password'),
                        Spacer(),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Auth.signOut();
                  if (context.mounted) {
                    _navigateToSignin(context);
                  }
                },
                icon: const Icon(Icons.logout, color: COLOR_WHITE),
                label: const Text('Sign out',
                    style: TextStyle(color: COLOR_WHITE)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIN_COLOR,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
