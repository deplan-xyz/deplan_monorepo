import 'package:deplan/models/subscription.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String orgId;
  final TextStyle titleStyle;
  final double planPrice;
  final double userPays;
  final double usagePercentage;
  final bool isEmpty;
  final String? avatar;
  final Color? backgroundColor;
  final Function(Subscription subscription)? onTap;

  SubscriptionCard({
    super.key,
    required this.title,
    required this.orgId,
    required this.planPrice,
    required this.userPays,
    required this.usagePercentage,
    this.avatar,
    this.isEmpty = false,
    this.titleStyle = const TextStyle(
      fontSize: 16,
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600,
      color: Color(0xff11243E),
    ),
    this.backgroundColor,
    this.onTap,
  });

  final ValueNotifier<double> _valueNotifier = ValueNotifier(37.0);

  @override
  Widget build(BuildContext context) {
    // final ValueNotifier<double> valueNotifier = ValueNotifier(usagePercentage);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          Subscription card = Subscription(
            name: title,
            youPay: userPays,
            orgId: orgId,
            planPrice: planPrice,
            usage: usagePercentage,
            logo: avatar,
          );
          onTap!(card);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xffE9E9EE).withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isEmpty
                  ? Icon(
                      null,
                      color: const Color(0xff11243E).withOpacity(0.4),
                      size: 60,
                    )
                  : avatar != null
                      ? Image.network(
                          avatar!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmpty ? 'App' : title,
                      style: titleStyle,
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Plan price',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              isEmpty
                                  ? '----'
                                  : '\$${planPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                color: const Color(0xff11243E).withOpacity(0.4),
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                decoration:
                                    isEmpty ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          children: [
                            const Text(
                              'You pay',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              isEmpty
                                  ? '----'
                                  : '\$${userPays.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                color: TEXT_MAIN,
                                fontWeight: isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 70,
              height: 70,
              child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1, // width ÷ height
                valueNotifier: _valueNotifier,
                progress: usagePercentage,
                startAngle: 240,
                sweepAngle: 240,
                foregroundColor: const Color(0xff00ADED),
                backgroundColor: const Color.fromARGB(255, 179, 158, 196),
                foregroundStrokeWidth: 8,
                backgroundStrokeWidth: 8,
                animation: true,
                seekSize: 5,
                maxProgress: 100.0,
                seekColor: Colors.white,
                child: ValueListenableBuilder(
                  valueListenable: _valueNotifier,
                  builder: (context, value, child) => Column(
                    children: [
                      const Text(''),
                      Text(
                        isEmpty ? '--%' : '${value.toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w800,
                          color: Color(0xff874AB6),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'Usage',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff874AB6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
