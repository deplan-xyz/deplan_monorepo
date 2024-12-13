import 'package:subdoor/api/auth_api.dart';
import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/balance.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/pages/account_settings_screen.dart';
import 'package:subdoor/pages/auctions_screen.dart';
import 'package:subdoor/pages/catalog_screen.dart';
import 'package:subdoor/pages/my_subscriptions_screen.dart';
import 'package:subdoor/pages/wallet/wallet_screen.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;

  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UserBalance> futureBalance;
  late Future<User> futureUser;
  late int _selectedTab;

  final double navBarHeight = 80;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    futureBalance = fetchBalance();
    futureUser = fetchUser();
  }

  Future<UserBalance> fetchBalance() async {
    final response = await userApi.getBalance();
    final balance = UserBalance.fromJson(response.data['balance']);
    return balance;
  }

  Future<User> fetchUser() async {
    final response = await authApi.getMe();
    return User.fromJson(response.data['user']);
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Widget buildBody(UserBalance balance, User user) {
    switch (_selectedTab) {
      case 0:
        return const CatalogScreen();
      case 1:
        return AuctionsScreen(balance: balance, user: user);
      case 2:
        return MySubscriptionsScreen(balance: balance, user: user);
      case 3:
        return WalletScreen(user: user, userBalance: balance);
      default:
        return const CatalogScreen();
    }
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
    String iconName,
    double iconWidth,
    double iconHeight,
    String label,
  ) {
    Widget wrapIcon(Widget icon) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Center(child: icon),
      );
    }

    return BottomNavigationBarItem(
      icon: wrapIcon(
        Image.asset(
          'assets/icons/$iconName.png',
          width: iconWidth,
          height: iconHeight,
        ),
      ),
      activeIcon: wrapIcon(
        Image.asset(
          'assets/icons/${iconName}_active.png',
          width: iconWidth,
          height: iconHeight,
        ),
      ),
      label: label,
    );
  }

  buildBottomNavigationBar() {
    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          buildBottomNavigationBarItem('catalog', 24, 24, 'Catalog'),
          buildBottomNavigationBarItem('auctions', 24, 24, 'Auctions'),
          buildBottomNavigationBarItem('subs', 30, 20, 'Subscriptions'),
          buildBottomNavigationBarItem('wallet_grey', 24, 21, 'Wallet'),
        ],
        currentIndex: _selectedTab,
        onTap: _onTabTapped,
      ),
    );
  }

  buildHeaderTitle(UserBalance balance, User user) {
    if (_selectedTab == 0 || _selectedTab == 1) {
      return Balance(
        balance: balance,
        user: user,
        onBalanceChange: (balance) {
          setState(() {
            futureBalance = Future.value(balance);
          });
        },
      );
    }
    return Image.asset(
      'assets/images/logo_with_text_inline.png',
      width: 150,
    );
  }

  buildHeader(UserBalance balance, User user) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHeaderTitle(balance, user),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsSreen(),
                ),
              );
            },
            icon: Image.asset(
              'assets/images/settings.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: FutureBuilder<List<Object>>(
        future: Future.wait([futureBalance, futureUser]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final balance = snapshot.data![0] as UserBalance;
          final user = snapshot.data![1] as User;

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: navBarHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    BodyPadding(
                      child: buildHeader(balance, user),
                    ),
                    Expanded(child: buildBody(balance, user)),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: buildBottomNavigationBar(),
              ),
            ],
          );
        },
      ),
    );
  }
}
