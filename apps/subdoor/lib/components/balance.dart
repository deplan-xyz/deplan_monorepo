import 'dart:async';

import 'package:subdoor/api/base_api.dart';
import 'package:subdoor/models/user.dart';
import 'package:subdoor/models/user_balance.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Balance extends StatefulWidget {
  final bool onlyBidBalance;
  final UserBalance balance;
  final User user;
  final Function(UserBalance)? onBalanceChange;

  const Balance({
    super.key,
    this.onlyBidBalance = false,
    required this.balance,
    required this.user,
    this.onBalanceChange,
  });

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  late final Socket socket;

  final StreamController<int> _streamController = StreamController<int>();

  Stream<int> get bidBalanceStream => _streamController.stream;

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
    socket.emit('balance_room', widget.user.id);
    socket.on('bids', (data) {
      _streamController.add(data['balance']);
      widget.onBalanceChange
          ?.call(widget.balance.copyWith(bidBalance: data['balance']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.onlyBidBalance)
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'sfprod',
              ),
              children: [
                TextSpan(
                  text:
                      '\$${widget.balance.usdcBalance.uiAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const TextSpan(
                  text: ' USDC',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        StreamBuilder<int>(
          stream: bidBalanceStream,
          initialData: widget.balance.bidBalance,
          builder: (context, snapshot) {
            return Text(
              '${snapshot.data} BIDS',
              style: const TextStyle(
                color: Color(0xff828C9A),
                fontFamily: 'sfprod',
                fontSize: 16,
              ),
            );
          },
        ),
      ],
    );
  }
}
