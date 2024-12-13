import 'package:subdoor/models/auction_item.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

class PayTimer extends StatefulWidget {
  final AuctionItem item;
  final VoidCallback? onFinished;

  const PayTimer({super.key, required this.item, this.onFinished});

  @override
  State<PayTimer> createState() => _PayTimerState();
}

class _PayTimerState extends State<PayTimer> {
  final payDuration = const Duration(milliseconds: 24 * 3600 * 1000);

  late DateTime endsAt;
  late Duration timeLeft;

  @override
  void initState() {
    super.initState();
    if (widget.item.endedAt != null) {
      endsAt = widget.item.endedAt!.add(payDuration);
    } else {
      endsAt = DateTime.now().toUtc();
    }
    if (endsAt.isBefore(DateTime.now().toUtc())) {
      timeLeft = Duration.zero;
    } else {
      timeLeft = endsAt.difference(DateTime.now().toUtc());
    }
    // Round up to nearest second to avoid showing 0:00 prematurely
    timeLeft = Duration(seconds: (timeLeft.inMilliseconds / 1000).ceil());
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
          style: TextStyle(
            fontFamily: 'sfprodbold',
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: remaining > 0
                ? const Color(0xffFF0C00)
                : const Color(0xff87899B),
            height: 1,
          ),
        );
      },
    );
  }
}
