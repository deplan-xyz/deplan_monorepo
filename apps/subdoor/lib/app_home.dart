import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/pages/login/login_screen.dart';
import 'package:flutter/material.dart';

class AppHome extends StatefulWidget {
  static const routeName = '/';

  const AppHome({super.key});

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
            backgroundColor: Colors.white,
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
