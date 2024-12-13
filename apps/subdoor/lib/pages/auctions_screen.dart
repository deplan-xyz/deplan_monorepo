import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/components/auction_card.dart';
import 'package:subdoor/components/search_field.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class AuctionsScreen extends StatefulWidget {
  final UserBalance balance;
  final User user;

  const AuctionsScreen({super.key, required this.balance, required this.user});

  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen> {
  late Future<List<AuctionItem>> futureAuctions;

  List<AuctionItem> allAuctions = [];

  @override
  void initState() {
    super.initState();
    futureAuctions = fetchAuctions();
  }

  Future<List<AuctionItem>> fetchAuctions() async {
    final response = await auctionApi.getAuctions(
      offerType: OfferType.auction.name,
      statuses: [AuctionStatus.active.name, AuctionStatus.pending.name],
    );
    allAuctions = (response.data['auctionItems'] as List)
        .map((item) => AuctionItem.fromJson(item))
        .toList();
    return allAuctions;
  }

  void _onSearch(String query) async {
    final filteredAuctions = allAuctions
        .where(
          (auction) => auction.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      futureAuctions = Future.value(filteredAuctions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Field
            Center(
              child: SearchField(
                onSearch: _onSearch,
              ),
            ),
            const SizedBox(height: 30),
            // Cards
            FutureBuilder<List<AuctionItem>>(
              future: futureAuctions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching auctions: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('There are no active auctions right now'),
                  );
                }
                return Column(
                  children: snapshot.data!
                      .map(
                        (item) => Column(
                          children: [
                            AuctionCard(
                              item: item,
                              balance: widget.balance,
                              user: widget.user,
                            ),
                            const SizedBox(height: 30),
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
