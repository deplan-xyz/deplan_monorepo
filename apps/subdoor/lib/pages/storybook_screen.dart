import 'package:subdoor/components/credit_card.dart';
import 'package:subdoor/api/data/mock_data.dart';
import 'package:subdoor/pages/wallet/wallet_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

class StorybookScreen extends StatelessWidget {
  const StorybookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      wrapperBuilder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getAppTheme(),
          home: Scaffold(
            body: Center(child: child ?? const SizedBox()),
          ),
        );
      },
      stories: [
        Story(
          name: 'Widgets/CreditCard',
          builder: (context) => CreditCard(
            item: auctionItem,
            cardDetails: creditCardDetails,
          ),
        ),
        Story(
          name: 'Screens/WalletScreen',
          builder: (context) => WalletScreen(
            user: user,
            userBalance: userBalance,
          ),
        ),
      ],
    );
  }
}
