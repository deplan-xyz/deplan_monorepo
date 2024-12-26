import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/app_home.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/credit_card_details.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/components/credit_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubscriptionAccessScreen extends StatefulWidget {
  final AuctionItem item;

  const SubscriptionAccessScreen({super.key, required this.item});

  @override
  State<SubscriptionAccessScreen> createState() =>
      _SubscriptionAccessScreenState();
}

class _SubscriptionAccessScreenState extends State<SubscriptionAccessScreen> {
  late Future<CreditCardDetails?> futureCardDetails;

  @override
  void initState() {
    super.initState();
    futureCardDetails = fetchCardDetails();
  }

  Future<CreditCardDetails?> fetchCardDetails() async {
    if (!widget.item.isPaid) {
      return null;
    }
    try {
      final response = await userApi.getCardDetails(widget.item.id);
      return CreditCardDetails.fromJson(response.data['cardDetails']);
    } on DioException catch (e) {
      _displayError(
        e.response?.data['message'] ?? 'Error fetching card details',
      );
      return null;
    }
  }

  void _displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildRedText(String text, context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xffFF0000),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.item.logo != null)
              Image.memory(
                widget.item.logo!,
                width: 30,
                height: 30,
                alignment: Alignment.center,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(widget.item.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Your payment was successful!',
                      style: TextStyle(
                        color: Color(0xff87899B),
                      ),
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    Text(
                      'Use this card to subscribe to ${widget.item.name}:',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'sfprod',
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    FutureBuilder<CreditCardDetails?>(
                      future: futureCardDetails,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data == null) {
                          return const Center(
                            child: Text('No card details found'),
                          );
                        }
                        return CreditCard(
                          item: widget.item,
                          cardDetails: snapshot.data!,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 34,
                    ),
                    buildRedText(
                      'This card works only with \$${widget.item.originalPrice} /mo ${widget.item.name} subscription.',
                      context,
                    ),
                    const SizedBox(
                      height: 34,
                    ),
                    buildRedText(
                      'In any other case card will be blocked.',
                      context,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 34,
          ),
          SizedBox(
            width: 287,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AppHome(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('GO TO HOME SCREEN'),
            ),
          ),
          const SizedBox(
            height: 34,
          ),
        ],
      ),
    );
  }
}
