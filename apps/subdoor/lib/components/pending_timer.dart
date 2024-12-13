import 'package:subdoor/models/auction_item.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

class PendingTimer extends StatefulWidget {
  final AuctionItem item;
  final VoidCallback? onFinished;

  const PendingTimer({super.key, required this.item, this.onFinished});

  @override
  State<PendingTimer> createState() => _PendingTimerState();
}

class _PendingTimerState extends State<PendingTimer> {
  late Duration timeLeft;

  @override
  void initState() {
    super.initState();
    if (widget.item.startsAt.isBefore(DateTime.now().toUtc())) {
      timeLeft = Duration.zero;
    } else {
      timeLeft = widget.item.startsAt.difference(DateTime.now().toUtc());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Countdown(
      seconds: timeLeft.inSeconds,
      onFinished: timeLeft.inSeconds > 0 ? widget.onFinished : null,
      build: (context, remaining) {
        final hours = remaining ~/ 3600;
        final minutes = (remaining / 60).floor() % 60;
        final seconds = remaining % 60;

        final hoursString = hours.toString().padLeft(2, '0');
        final minutesString = minutes.toString().padLeft(2, '0');
        final secondsString = seconds.toString().padLeft(2, '0');

        return Text(
          '$hoursString:$minutesString:$secondsString',
          style: const TextStyle(
            fontFamily: 'sfprodbold',
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Color(0xff87899B),
            height: 1,
          ),
        );
      },
    );
  }
}
