import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/pages/login/signup_basic_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:subdoor/widgets/input_form.dart';
import 'package:subdoor/widgets/keyboard_dismissable_list.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class LoginUsernameScreen extends StatefulWidget {
  const LoginUsernameScreen({super.key});

  @override
  State<LoginUsernameScreen> createState() => _LoginUsernameScreenState();
}

class _LoginUsernameScreenState extends State<LoginUsernameScreen> {
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
      await authApi.signinBasic(_email, _password);
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
        backgroundColor: errorColor,
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Login with Email'),
      ),
      body: BodyPadding(
        child: Form(
          key: _formKey,
          child: KeyboardDismissableListView(
            children: [
              const SizedBox(height: 35),
              AppTextFormFieldBordered(
                labelText: 'Email',
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
                inputType: TextInputType.emailAddress,
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
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 290,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Login'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupUsernameScreen(),
                      ),
                    );
                  },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
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
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Enter a valid email address';
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
