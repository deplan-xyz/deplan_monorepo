import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/screens/home_screen.dart';
import 'package:phorevr/screens/login/login_email_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/widgets/form/input_form.dart';
import 'package:phorevr/widgets/list/keyboard_dismissable_list.dart';
import 'package:phorevr/widgets/view/app_padding.dart';
import 'package:phorevr/widgets/view/screen_scaffold.dart';
import 'package:email_validator/email_validator.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({Key? key}) : super(key: key);

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  String _email = '';
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
      await authApi.signupEmail(_email, _password);
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
      title: 'Sign Up with Email',
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
                      validator: _validatePassword,
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextFormFieldBordered(
                      labelText: 'Confirm Password',
                      inputType: TextInputType.visiblePassword,
                      validator: _validateConfirmPassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 290,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginEmailScreen(),
                    ),
                  );
                },
                child: const Text('Already have an account? Log in'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
