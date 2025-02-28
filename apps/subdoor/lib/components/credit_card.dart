import 'package:intl/intl.dart';
import 'package:subdoor/components/text_copy.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/models/credit_card_details.dart';
import 'package:subdoor/pages/topup_screen.dart';
import 'package:flutter/material.dart';
import 'package:subdoor/utils/payment.dart';

class CreditCard extends StatefulWidget {
  final AuctionItem item;
  final CreditCardDetails cardDetails;

  const CreditCard({super.key, required this.item, required this.cardDetails});

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  num count = 0;

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
    final nextPaymentAt = calculateNextPaymentAt(
      widget.item.subscribedAt!,
      widget.item.subscriptionFrequency,
    );
    final formattedDate = DateFormat('dd MMM yyyy').format(nextPaymentAt);
    final message = 'Next payment $formattedDate';

    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xffC60003),
      ),
    );
  }

  handleTopUpPressed(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopupScreen(item: widget.item),
      ),
    );
  }

  Widget buildBalance() {
    Color? color = widget.cardDetails.balance < widget.item.originalPrice ||
            widget.cardDetails.status == CreditCardStatus.blocked
        ? const Color(0xffC60003)
        : null;
    String title = 'Balance: \$${widget.cardDetails.balance}';

    if (widget.cardDetails.status == CreditCardStatus.blocked) {
      title = 'Card Blocked';
    }

    return Text(
      title,
      style: TextStyle(color: color, fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Align(
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
            height: 285,
            width: 352,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.item.subscribedAt != null
                        ? buildPaymentDate()
                        : const SizedBox(),
                    SizedBox(
                      height: 29,
                      child: ElevatedButton(
                        onPressed: () => handleTopUpPressed(context),
                        child: const Text(
                          '+ Top-Up',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                buildBalance(),
              ],
            ),
          ),
        ),
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
                                      '\$${widget.item.originalPrice} /${AuctionItem.formatFrequencyShort(widget.item.subscriptionFrequency)}',
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
                              if (widget.item.logo != null)
                                Container(
                                  width: 50,
                                  height: 50,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Image.memory(
                                    widget.item.logo!,
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
