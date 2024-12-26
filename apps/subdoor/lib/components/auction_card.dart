import 'dart:async';

import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/api/base_api.dart';
import 'package:subdoor/components/auction_timer.dart';
import 'package:subdoor/components/bid_button.dart';
import 'package:subdoor/components/pay_button.dart';
import 'package:subdoor/components/pay_timer.dart';
import 'package:subdoor/components/pending_timer.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/pages/auction_details_screen.dart';
import 'package:subdoor/pages/subscription_access_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AuctionCard extends StatefulWidget {
  final UserBalance balance;
  final User user;
  final AuctionItem item;

  const AuctionCard({
    super.key,
    required this.item,
    required this.balance,
    required this.user,
  });

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  late final Socket socket;

  final StreamController<AuctionItem> _streamController =
      StreamController<AuctionItem>();

  bool isBidding = false;

  Stream<AuctionItem> get auctionStream => _streamController.stream;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  @override
  void dispose() {
    super.dispose();
    socket.dispose();
    _streamController.close();
  }

  initSocket() {
    socket = io(server['ws']!, OptionBuilder().enableForceNew().build());
    socket.emit('auction_room', widget.item.id);
    socket.on('update', (data) {
      setState(() {
        isBidding = false;
      });
      _streamController.add(AuctionItem.fromJson(data['auctionItem']));
    });
  }

  void handleBidPressed() async {
    setState(() {
      isBidding = true;
    });
    try {
      await auctionApi.bid(widget.item.id);
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        _displayError(e.response!.data['message']);
      } else {
        _displayError('Error placing bid. Please try again.');
      }
      setState(() {
        isBidding = false;
      });
    } catch (e) {
      _displayError('Error placing bid. Please try again.');
      setState(() {
        isBidding = false;
      });
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

  void navigateToDetails(AuctionItem item, bool hasWon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => hasWon && item.isPaid
            ? SubscriptionAccessScreen(item: item)
            : AuctionDetailsScreen(
                item: item,
                balance: widget.balance,
                user: widget.user,
              ),
      ),
    );
  }

  void navigateSubscriptionAccess(AuctionItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionAccessScreen(item: item),
      ),
    );
  }

  Widget buildTimer(AuctionItem item, bool hasWon) {
    if (item.status == AuctionStatus.pending) {
      return PendingTimer(item: item);
    }
    if (hasWon) {
      if (item.isPaid) {
        return const SizedBox.shrink();
      }
      return PayTimer(item: item);
    }
    return AuctionTimer(
      key: ValueKey(item.lastBidAt?.toIso8601String()),
      item: item,
      onFinished: () {
        final endedItem = item.copyWith(
          status: AuctionStatus.ended,
          endedAt: DateTime.now().toUtc(),
        );
        _streamController.add(endedItem);
      },
    );
  }

  Widget buildButton(AuctionItem item, bool hasWon) {
    return hasWon
        ? item.isPaid
            ? ElevatedButton(
                onPressed: () => navigateSubscriptionAccess(item),
                child: const Text('GET ACCESS'),
              )
            : PayButton(
                item: item,
                onPaid: (item) => navigateSubscriptionAccess(item),
              )
        : BidButton(
            item: item,
            user: widget.user,
            onPressed: item.status != AuctionStatus.active || isBidding
                ? null
                : handleBidPressed,
          );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuctionItem>(
      stream: auctionStream,
      initialData: widget.item,
      builder: (context, snapshot) {
        final item = snapshot.data!;
        final hasWon = item.status == AuctionStatus.ended &&
            widget.user.id == item.lastBidBy;

        return InkWell(
          onTap: () => navigateToDetails(item, hasWon),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color(0xffF4F4F6),
              border: Border.all(
                color: const Color(0xffD5D5D5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Logo
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.item.logo != null)
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.memory(widget.item.logo!),
                                ),
                              ),
                            // Title + original price
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'sfprodmedium',
                                    ),
                                  ),
                                  const Text(
                                    'Original subscription price',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Color(0x8011243E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'sfprod',
                                    ),
                                  ),
                                  Text(
                                    '\$${item.originalPrice.toStringAsFixed(2)} / ${AuctionItem.formatFrequencyShort(item.subscriptionFrequency)}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Color(0x8011243E),
                                      color: Color(0x8011243E),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'sfprodmedium',
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Current Bid
                      Column(
                        children: [
                          const Text(
                            'Current bid',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Color(0xB211243E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'sfprod',
                            ),
                          ),
                          Text(
                            '\$${item.currentPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: item.currentPrice > 0
                                  ? const Color(0xff00A310)
                                  : const Color(0xff87899B),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'sfprodbold',
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // bottom body
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      buildTimer(item, hasWon),
                      const SizedBox(height: 15),
                      // Start Button
                      SizedBox(
                        width: 290,
                        child: buildButton(item, hasWon),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
