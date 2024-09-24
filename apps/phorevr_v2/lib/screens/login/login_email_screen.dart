import 'package:flutter/material.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/screens/home_screen.dart';
import 'package:phorevr/screens/login/signup_email_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/widgets/form/input_form.dart';
import 'package:phorevr/widgets/list/keyboard_dismissable_list.dart';
import 'package:phorevr/widgets/view/app_padding.dart';
import 'package:phorevr/widgets/view/screen_scaffold.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({Key? key}) : super(key: key);

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authApi.signinEmail(_email, _password);
      _navigateToHomeScreen();
    } catch (e) {
      _displayError('Login failed. Please check your credentials.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Login with Email',
      child: AppPadding(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Expanded(
                child: KeyboardDismissableListView(
                  children: [
                    const SizedBox(height: 35),
                    AppTextFormFieldBordered(
                      labelText: 'Email',
                      inputType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextFormFieldBordered(
                      labelText: 'Password',
                      inputType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      validator: _validatePassword,
                      onChanged: (value) {
                        setState(() {
                          _password = value;
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
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupEmailScreen(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
