import 'package:flutter/material.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/screens/home_screen.dart';
import 'package:phorevr/screens/login_screen.dart';
import 'package:phorevr/theme/app_theme.dart';

class AppHome extends StatefulWidget {
  static const routeName = '/';

  const AppHome({Key? key}) : super(key: key);

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  late Future<User?> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = initUser();
  }

  Future<User?> initUser() async {
    final response = await authApi.getMe();
    return User.fromJson(response.data['user']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const LoginScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: APP_BODY_BG,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const HomeScreen();
      },
    );
  }
}
