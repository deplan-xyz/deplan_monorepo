import 'package:flutter/material.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/api/balance_api.dart';
import 'package:phorevr/models/token_amount.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/screens/account/components/account_header.dart';
import 'package:phorevr/screens/account/components/account_title.dart';
import 'package:phorevr/screens/account/components/account_title_shimmer.dart';
import 'package:phorevr/widgets/view/screen_scaffold.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late Future<User?> futureUser;
  late Future<String?> futureBalance;

  @override
  void initState() {
    futureUser = fetchUser();
    futureBalance = fetchBalance();
    super.initState();
  }

  Future<User?> fetchUser() async {
    try {
      final response = await authApi.getMe();
      return User.fromJson(response.data['user']);
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<String?> fetchBalance() async {
    final response = await balanceApi.getBalance();
    return TokenAmount.fromJson(response.data['balance']).uiAmountString;
  }

  Future onRefresh() {
    setState(() {
      futureUser = fetchUser();
      futureBalance = fetchBalance();
    });
    return Future.wait([futureUser, futureBalance]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureUser,
      builder: (_, snapshot) {
        return ScreenScaffold(
          title: FutureBuilder(
            future: futureUser,
            builder: (context, snapshot) {
              final user = snapshot.data;
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!snapshot.hasData) const AccountTitleShimmer(),
                  if (snapshot.hasData) AccountTitle(user: user),
                ],
              );
            },
          ),
          child: FutureBuilder(
            future: futureUser,
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final user = snapshot.data;
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder(
                    future: futureBalance,
                    builder: (_, snapshot) {
                      return AccountHeader(balance: snapshot.data, user: user);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
