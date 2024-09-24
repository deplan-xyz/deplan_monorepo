import 'package:flutter/material.dart';
import 'package:deplan_v1/api/auth_api.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/screens/home_screen.dart';
import 'package:deplan_v1/screens/login_screen.dart';
import 'package:deplan_v1/theme/app_theme.dart';

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
    await authApi.initWallet();
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
