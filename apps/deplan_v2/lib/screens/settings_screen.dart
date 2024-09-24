import 'package:deplan_subscriptions_client/api/auth.dart';
import 'package:deplan_subscriptions_client/components/screen_wrapper.dart';
import 'package:deplan_subscriptions_client/constants/routes.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  _navigateToSignin(BuildContext context) {
    Navigator.pushNamed(context, Routes.signin);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await Auth.signOut();
              if (context.mounted) {
                _navigateToSignin(context);
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sign out', style: TextStyle(color: Colors.red)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: const BorderSide(color: Colors.red), // Added red border
            ),
          ),
        ],
      ),
    );
  }
}
