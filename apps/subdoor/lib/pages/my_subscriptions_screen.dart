import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/search_field.dart';
import 'package:subdoor/components/subscription_card.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class MySubscriptionsScreen extends StatefulWidget {
  final UserBalance balance;
  final User user;

  const MySubscriptionsScreen({
    super.key,
    required this.balance,
    required this.user,
  });

  @override
  State<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends State<MySubscriptionsScreen> {
  late Future<List<AuctionItem>> futureSubscriptions;

  List<AuctionItem> allSubscriptions = [];

  @override
  void initState() {
    super.initState();
    futureSubscriptions = fetchSubscriptions();
  }

  Future<List<AuctionItem>> fetchSubscriptions() async {
    final response = await userApi.getSubscriptions();
    allSubscriptions = (response.data['subscriptions'] as List)
        .map((e) => AuctionItem.fromJson(e))
        .toList();
    return allSubscriptions;
  }

  void _onSearch(String query) async {
    final filteredSubscriptions = allSubscriptions
        .where(
          (subscription) =>
              subscription.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      futureSubscriptions = Future.value(filteredSubscriptions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SearchField(onSearch: _onSearch),
            ),
            const SizedBox(height: 30),
            FutureBuilder<List<AuctionItem>>(
              future: futureSubscriptions,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final subscriptions = snapshot.data!;

                if (subscriptions.isEmpty) {
                  return const Center(child: Text('No subscriptions found'));
                }

                return Column(
                  children: subscriptions
                      .map(
                        (e) => Column(
                          children: [
                            SubscriptionCard(
                              item: e,
                              balance: widget.balance,
                              user: widget.user,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
