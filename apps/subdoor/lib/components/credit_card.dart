import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/payment_confirmation.dart';
import 'package:subdoor/components/text_copy.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/credit_card_details.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CreditCard extends StatefulWidget {
  final AuctionItem item;
  final CreditCardDetails cardDetails;

  const CreditCard({super.key, required this.item, required this.cardDetails});

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  num count = 0;
  bool isLoading = false;

  Widget buildTextRow(
    BuildContext context,
    String text, {
    String? title,
    String Function(String)? textFormatter,
  }) {
    return InkWell(
      onTap: () => copyText(context, text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'ibmplex',
              fontSize: 14,
              color: Color.fromRGBO(255, 255, 255, 0.54),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            children: [
              TextSpan(
                text: title != null ? '$title ' : '',
              ),
              TextSpan(
                text: textFormatter != null ? textFormatter(text) : text,
                style: const TextStyle(color: Colors.white),
              ),
              const WidgetSpan(
                child: SizedBox(
                  width: 5,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Image.asset(
                  'assets/images/copy.png',
                  alignment: Alignment.topRight,
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildViewButton(String text) {
    return SizedBox(
      height: 22,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            count++;
            if (count == 2) {
              count = 0;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          backgroundColor: const Color(0x40D9D9D9),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'sfprod',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget buildPaymentDate() {
    Jiffy now = Jiffy.now();
    Jiffy subscribedAt =
        Jiffy.parse(widget.item.subscribedAt.toString(), isUtc: true).toLocal();
    num diff = 0;
    Jiffy nextPaymentAt = subscribedAt;

    if (widget.item.subscriptionFrequency == SubscriptionFrequency.weekly) {
      diff = now
          .startOf(Unit.day)
          .diff(subscribedAt.startOf(Unit.day), unit: Unit.week);
      if (now.date >= subscribedAt.add(weeks: diff.toInt()).date) {
        diff += 1;
      }
      nextPaymentAt = subscribedAt.add(weeks: diff.toInt());
    } else if (widget.item.subscriptionFrequency ==
        SubscriptionFrequency.monthly) {
      diff = now
          .startOf(Unit.month)
          .diff(subscribedAt.startOf(Unit.month), unit: Unit.month);
      bool isLastDayOfMonth = now.daysInMonth == now.date;
      if (now.date >= subscribedAt.date || isLastDayOfMonth) {
        diff += 1;
      }
      nextPaymentAt = subscribedAt.add(months: diff.toInt());
    } else {
      diff = now
          .startOf(Unit.year)
          .diff(subscribedAt.startOf(Unit.year), unit: Unit.year);
      if (now
              .format(pattern: 'MM-dd')
              .compareTo(subscribedAt.format(pattern: 'MM-dd')) >=
          0) {
        diff += 1;
      }
      nextPaymentAt = subscribedAt.add(years: diff.toInt());
    }

    String message =
        'Next payment ${nextPaymentAt.format(pattern: 'dd MMM yyyy')}';

    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xffC60003),
      ),
    );
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

  void _displaySuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  handleTopUpPressed() async {
    final confirmed = await showAppBottomSheet(
      context,
      (context) => PaymentConfirmation(
        logo: widget.item.logo,
        label:
            '\$${widget.item.originalPrice} USDC /${widget.item.formattedFrequency}',
        title:
            'Top-Up ${widget.item.name} card for \$${widget.item.originalPrice} USDC',
        description:
            '\$${widget.item.originalPrice} USDC will be charged from your Subdoor balance',
        onCancel: () => Navigator.pop(context),
        onConfirm: () => Navigator.pop(context, true),
      ),
      backgroundColor: const Color(0xff11243E),
    );
    if (confirmed != null && confirmed) {
      setState(() {
        isLoading = true;
      });
      try {
        await userApi.topUpSubscription(widget.item.id);
        _displaySuccess('Card top-up successful');
      } on DioException catch (e) {
        _displayError(
          e.response?.data['message'] ?? 'Error paying subscription',
        );
      } catch (e) {
        _displayError('Error paying subscription');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.item.subscribedAt != null
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xffD5D5D5),
                    ),
                  ),
                  height: 260,
                  width: 352,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildPaymentDate(),
                      SizedBox(
                        height: 29,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleTopUpPressed,
                          child: Text(
                            isLoading ? 'Processing...' : '+ Top-Up',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        Container(
          width: 352,
          height: 206,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF87899B),
                      Color(0xFF38536B),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/circles.png',
              ),
              Container(
                padding: const EdgeInsets.only(
                  right: 20.96,
                  left: 26.78,
                  top: 22.37,
                  bottom: 20,
                ),
                child: count == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.item.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'ibmplexsans',
                                        fontSize: 16,
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.75,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${widget.item.originalPrice} /${widget.item.formattedFrequency}',
                                      style: const TextStyle(
                                        fontFamily: 'ibmplex',
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Image.memory(
                                  widget.item.logo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTextRow(
                                context,
                                widget.cardDetails.cardNumber,
                                textFormatter: (text) =>
                                    '${text.substring(0, 4)} ${text.substring(4, 8)} ${text.substring(8, 12)} ${text.substring(12)}',
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              buildTextRow(
                                context,
                                widget.cardDetails.expiryDate,
                                title: 'EXP',
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildTextRow(
                                    context,
                                    widget.cardDetails.cvv,
                                    title: 'CVC',
                                  ),
                                  buildViewButton(
                                    'Tap to view billing address →',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildTextRow(
                            context,
                            widget.cardDetails.address,
                            title: 'ADDRESS',
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTextRow(
                                context,
                                widget.cardDetails.city,
                                title: 'CITY',
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              buildTextRow(
                                context,
                                widget.cardDetails.state,
                                title: 'STATE',
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              buildTextRow(
                                context,
                                widget.cardDetails.zip,
                                title: 'ZIP',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: buildViewButton(
                                  'Back to view card details →',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
