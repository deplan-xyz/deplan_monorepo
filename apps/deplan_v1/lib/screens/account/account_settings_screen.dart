import 'package:deplan/models/app_link/app_link_data.dart';
import 'package:deplan/models/app_link/app_link_type.dart';
import 'package:deplan/screens/qr_scanner_screen.dart';
import 'package:deplan/services/app_link_service.dart';
import 'package:deplan/widgets/buttons/gray_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deplan/api/auth_api.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/widgets/view/app_padding.dart';
import 'package:deplan/widgets/view/screen_scaffold.dart';
import 'package:provider/provider.dart';

class AccountSettingsSreen extends StatelessWidget {
  const AccountSettingsSreen({super.key});

  navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  handleLogoutPressed(BuildContext context) async {
    authApi.logout();
    if (context.mounted) {
      navigateToLogin(context);
    }
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

  handleWalletConnectPressed(BuildContext context) async {
    final data = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const QrScannerScreen(),
      ),
    );
    if (context.mounted && data != null) {
      context.read<AppLinkService>().addData(AppLinkData(AppLinkType.wc, data));
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
            GrayButton(
              onPressed: () => handleWalletConnectPressed(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('WalletConnect'),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset('assets/images/wc_logo.png'),
                    ),
                  ),
                ],
              ),
            ),
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
                onPressed: () => handleLogoutPressed(context),
                icon: SvgPicture.asset(
                  'assets/icons/logout_icon.svg',
                  colorFilter:
                      const ColorFilter.mode(COLOR_RED, BlendMode.srcIn),
                ),
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
