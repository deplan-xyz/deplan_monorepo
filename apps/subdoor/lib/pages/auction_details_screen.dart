import 'dart:async';
import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/api/base_api.dart';
import 'package:subdoor/components/auction_timer.dart';
import 'package:subdoor/components/balance.dart';
import 'package:subdoor/components/bid_button.dart';
import 'package:subdoor/components/pending_timer.dart';
import 'package:subdoor/components/win_section.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/bid_history_item.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AuctionDetailsScreen extends StatefulWidget {
  final UserBalance balance;
  final AuctionItem item;
  final User user;

  const AuctionDetailsScreen({
    super.key,
    required this.item,
    required this.balance,
    required this.user,
  });

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen> {
  late final Socket socket;
  late final Future<List<BidHistoryItem>> futureBidHistory;

  final StreamController<AuctionItem> _streamController =
      StreamController<AuctionItem>();
  final newHistoryItems = <BidHistoryItem>[];

  bool isBidding = false;

  Stream<AuctionItem> get auctionStream => _streamController.stream;

  @override
  void initState() {
    super.initState();
    initSocket();
    futureBidHistory = fetchBidHistory();
  }

  @override
  void dispose() {
    super.dispose();
    socket.dispose();
    _streamController.close();
  }

  void initSocket() {
    socket = io(server['ws']!, OptionBuilder().enableForceNew().build());
    socket.emit('auction_room', widget.item.id);
    socket.on('update', (data) {
      setState(() {
        isBidding = false;
      });
      _streamController.add(AuctionItem.fromJson(data['auctionItem']));
    });
    socket.on('bid', (data) {
      setState(() {
        insertBidHistoryItem(BidHistoryItem.fromJson(data['bidHistoryItem']));
      });
    });
  }

  Future<List<BidHistoryItem>> fetchBidHistory() async {
    final response = await auctionApi.getBidHistory(widget.item.id);
    return (response.data['bidHistory'] as List)
        .map((item) => BidHistoryItem.fromJson(item))
        .toList();
  }

  void insertBidHistoryItem(BidHistoryItem item) {
    newHistoryItems.insert(0, item);
    newHistoryItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  Widget buildStep(AuctionItem item) {
    if (item.status == AuctionStatus.ended &&
        widget.user.id == item.lastBidBy) {
      return SingleChildScrollView(
        child: WinSection(
          balance: widget.balance,
          auctionItem: item,
        ),
      );
    }
    return buildHistory();
  }

  Widget buildHistory() {
    return FutureBuilder<List<BidHistoryItem>>(
      future: futureBidHistory,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.data!.isEmpty && newHistoryItems.isEmpty) {
          return const Center(child: Text('No bids yet'));
        }

        final bidHistory = snapshot.data!;

        return Column(
          children: [
            const BodyPadding(
              verticalPadding: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Bid',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'User',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: newHistoryItems.length + bidHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = index < newHistoryItems.length
                      ? newHistoryItems[index]
                      : bidHistory[index - newHistoryItems.length];
                  final color = index == 0 ? const Color(0xff00A310) : null;
                  final formattedTime = DateFormat('HH:mm:ss').format(
                    item.createdAt.toLocal(),
                  );
                  return BodyPadding(
                    verticalPadding: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '\$${item.bidAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: color),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '@${item.user.username}',
                                style: TextStyle(color: color),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formattedTime,
                                style: TextStyle(color: color),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTimer(AuctionItem item) {
    if (item.status == AuctionStatus.pending) {
      return PendingTimer(item: item);
    }
    return AuctionTimer(
      key: ValueKey(item.lastBidAt?.toIso8601String()),
      item: item,
      onFinished: () {
        _streamController.add(
          item.copyWith(
            status: AuctionStatus.ended,
            endedAt: DateTime.now().toUtc(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuctionItem>(
      stream: auctionStream,
      initialData: widget.item,
      builder: (context, snapshot) {
        final auctionItem = snapshot.data!;
        final hasWon = auctionItem.status == AuctionStatus.ended &&
            widget.user.id == auctionItem.lastBidBy;

        return AppScaffold(
          appBar: AppBar(
            centerTitle: true,
            scrolledUnderElevation: 0.0,
            backgroundColor: const Color(0xffFFFFFF),
            // Logo + Title
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (auctionItem.logo != null)
                  Image.memory(
                    auctionItem.logo!,
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                  ),
                const SizedBox(
                  width: 5,
                ),
                Text(auctionItem.name),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BodyPadding(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Original subscription price',
                          style: TextStyle(
                            fontFamily: 'sfprod',
                            fontSize: 14,
                            color: Color(0x8011243E),
                            fontWeight: FontWeight.w400,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          '\$${auctionItem.originalPrice.toStringAsFixed(2)} / ${AuctionItem.formatFrequencyShort(auctionItem.subscriptionFrequency)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color(0x8011243E),
                            fontFamily: 'sfprodmedium',
                            fontSize: 30,
                            color: Color(0x8011243E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Current bid',
                          style: TextStyle(
                            fontFamily: 'sfprod',
                            fontSize: 18,
                            color: Color(0xB211243E),
                            fontWeight: FontWeight.w400,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          '\$${auctionItem.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'sfprodbold',
                            fontSize: 30,
                            color: Color(0xff00A310),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              // Titles of Columns
              Expanded(child: buildStep(auctionItem)),
              const SizedBox(
                height: 20,
              ),
              if (!hasWon)
                Column(
                  children: [
                    Center(
                      child: buildTimer(auctionItem),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: SizedBox(
                        width: 290,
                        child: BidButton(
                          item: auctionItem,
                          user: widget.user,
                          onPressed:
                              auctionItem.status != AuctionStatus.active ||
                                      isBidding
                                  ? null
                                  : handleBidPressed,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Balance(
                          balance: widget.balance,
                          onlyBidBalance: true,
                          user: widget.user,
                        ),
                        const Text(
                          ' left',
                          style: TextStyle(
                            color: Color(0xff828C9A),
                            fontFamily: 'sfprod',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
