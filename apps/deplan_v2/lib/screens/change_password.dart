import 'package:deplan/api/auth.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/components/ui_notifications.dart';
import 'package:deplan/screens/signin.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController =
        TextEditingController();

    navigateToSignin(BuildContext context) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
      );
    }

    onPasswordChanged(BuildContext context) async {
      final password = newPasswordController.text;
      final confirmPassword = confirmNewPasswordController.text;
      final currentPassword = currentPasswordController.text;

      if (currentPassword.isEmpty) {
        showSnackBar(
          context,
          'Please enter your current password',
        );
        return;
      }

      if (password.isEmpty || confirmPassword.isEmpty) {
        showSnackBar(
          context,
          'Please enter your password',
        );
        return;
      }

      if (password != confirmPassword) {
        showSnackBar(context, 'Passwords do not match');
        return;
      }

      try {
        await Auth.changePassword(currentPassword, password);
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          showSnackBar(context, e.message ?? 'Error changing password');
        }
        return;
      } catch (e) {
        if (context.mounted) {
          showSnackBar(context, e.toString());
        }
        return;
      }

      await Auth.signOut();
      if (context.mounted) {
        navigateToSignin(context);
        showSnackBar(
          context,
          'Password changed successfully',
          type: SnackBarType.success,
          duration: const Duration(seconds: 1),
        );
      }
    }

    return ScreenWrapper(
      showAppBar: true,
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: MAIN_COLOR),
                ),
                hintText: 'Current Password',
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: MAIN_COLOR),
                ),
                hintText: 'New Password',
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () async {
                await onPasswordChanged(context);
              },
              label: const Text(
                'Change Password',
                style: TextStyle(color: COLOR_WHITE),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MAIN_COLOR,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
