import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/pages/login/login_basic_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:subdoor/widgets/input_form.dart';
import 'package:subdoor/widgets/keyboard_dismissable_list.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class SignupUsernameScreen extends StatefulWidget {
  const SignupUsernameScreen({super.key});

  @override
  State<SignupUsernameScreen> createState() => _SignupUsernameScreenState();
}

class _SignupUsernameScreenState extends State<SignupUsernameScreen> {
  String _email = '';
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await authApi.signupBasic(_email, _username, _password);
      _navigateToHomeScreen();
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        _displayError(e.response!.data['message']);
      } else {
        _displayError('Signup failed. Please try again.');
      }
    } catch (e) {
      _displayError('Signup failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != _password) {
      return 'Passwords do not match';
    }
    return null;
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
        title: const Text('Sign Up with Email'),
      ),
      body: BodyPadding(
        child: Form(
          key: _formKey,
          child: KeyboardDismissableListView(
            children: [
              const SizedBox(height: 35),
              AppTextFormFieldBordered(
                textInputAction: TextInputAction.next,
                labelText: 'Email',
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
                textInputAction: TextInputAction.next,
                labelText: 'Username',
                validator: _validateUsername,
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              AppTextFormFieldBordered(
                textInputAction: TextInputAction.next,
                labelText: 'Password',
                inputType: TextInputType.visiblePassword,
                validator: _validatePassword,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              AppTextFormFieldBordered(
                textInputAction: TextInputAction.done,
                labelText: 'Confirm Password',
                inputType: TextInputType.visiblePassword,
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 290,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Sign Up'),
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
                        builder: (context) => const LoginUsernameScreen(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Log in'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
