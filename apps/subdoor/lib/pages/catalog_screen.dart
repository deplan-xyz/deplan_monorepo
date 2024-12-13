import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/components/catalog_card.dart';
import 'package:subdoor/components/search_field.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<AuctionItem>> futureOffers;

  List<AuctionItem> allOffers = [];

  @override
  void initState() {
    super.initState();
    futureOffers = fetchOffers();
  }

  Future<List<AuctionItem>> fetchOffers() async {
    final response = await auctionApi.getAuctions(
      offerType: OfferType.buy_now.name,
      statuses: [AuctionStatus.active.name],
    );
    allOffers = (response.data['auctionItems'] as List)
        .map((item) => AuctionItem.fromJson(item))
        .toList();
    return allOffers;
  }

  void _onSearch(String query) async {
    final filteredOffers = allOffers
        .where(
          (offer) => offer.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      futureOffers = Future.value(filteredOffers);
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
              child: SearchField(onSearch: _onSearch),
            ),
            const SizedBox(height: 30),
            // Cards
            FutureBuilder<List<AuctionItem>>(
              future: futureOffers,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching offers: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('There are no offers right now'),
                  );
                }
                return Column(
                  children: snapshot.data!
                      .map(
                        (item) => Column(
                          children: [
                            CatalogCard(item: item),
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
