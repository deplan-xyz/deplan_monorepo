import 'package:deplan_v1/constants.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_store/open_store.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  navigateToStore() {
    OpenStore.instance.open(
      appStoreId: APP_STORE_ID,
      androidAppBundleId: ANDROID_APP_BUNDLE_ID,
    );
    // launchUrl(Uri.parse('solanadappstore://details?id=xyz.deplan.app'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: AppPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_with_text.png',
                  width: 250,
                ),
              ),
              const SizedBox(height: 70),
              const Text(
                'Your version is outdated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 80),
              const Text(
                'Please update the app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: navigateToStore,
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
