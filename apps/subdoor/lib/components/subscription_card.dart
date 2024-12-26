import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/auction_card.dart';
import 'package:subdoor/components/credit_card.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/credit_card_details.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatefulWidget {
  final AuctionItem item;
  final UserBalance balance;
  final User user;

  const SubscriptionCard({
    super.key,
    required this.item,
    required this.balance,
    required this.user,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
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

  @override
  Widget build(BuildContext context) {
    return widget.item.isPaid
        ? FutureBuilder<CreditCardDetails?>(
            future: futureCardDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data == null) {
                return Center(
                  child: Text(
                    'Your ${widget.item.name} card is being issued...',
                  ),
                );
              }
              return CreditCard(
                item: widget.item,
                cardDetails: snapshot.data!,
              );
            },
          )
        : AuctionCard(
            item: widget.item,
            balance: widget.balance,
            user: widget.user,
          );
  }
}
