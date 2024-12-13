import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/user.dart';
import 'package:flutter/material.dart';

class BidButton extends StatelessWidget {
  final AuctionItem item;
  final User user;
  final VoidCallback? onPressed;

  bool get isWinning => user.id == item.lastBidBy;

  const BidButton({
    super.key,
    required this.item,
    required this.user,
    required this.onPressed,
  });

  String buildButtonText(AuctionStatus status) {
    return status == AuctionStatus.active
        ? isWinning
            ? 'YOU ARE WINNING!'
            : 'BID NOW'
        : status == AuctionStatus.cancelled
            ? 'CANCELLED'
            : status == AuctionStatus.pending
                ? 'STARTING SOON'
                : 'ENDED';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isWinning ? const Color(0xff00A310) : null,
      ),
      child: Text(buildButtonText(item.status)),
    );
  }
}
