import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:deplan_v1/api/auth_api.dart';
import 'package:deplan_v1/screens/home_screen.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/utils/crypto.dart';
import 'package:deplan_v1/widgets/form/input_form.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';

class RestoreAccountScreen extends StatefulWidget {
  const RestoreAccountScreen({Key? key}) : super(key: key);

  @override
  State<RestoreAccountScreen> createState() => _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends State<RestoreAccountScreen> {
  String _restoreCode = '';
  bool _isLoading = false;

  restoreAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final entropy = CryptoUtils.secretCodeToEntropy(_restoreCode);
      final password = await CryptoUtils.getPassword(entropy);
      final keypair = await CryptoUtils.generateKeypair(entropy);
      await authApi.restore(keypair, password);
      navigateToHomeScreen();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        displayError(e.response?.data['message']);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Login via Secret Сode',
      child: AppPadding(
        child: Column(
          children: <Widget>[
            Expanded(
              child: KeyboardDismissableListView(
                children: [
                  const SizedBox(height: 35),
                  const Text(
                    'Paste your secret code to get access to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: COLOR_ALMOST_BLACK,
                    ),
                  ),
                  const SizedBox(height: 15),
                  AppTextFormFieldBordered(
                    maxLines: 6,
                    minLines: 6,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        _restoreCode = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 290,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        restoreAccount();
                      },
                child: _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
