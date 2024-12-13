import 'package:subdoor/components/pay_button.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/pages/subscription_access_screen.dart';
import 'package:flutter/material.dart';

class CatalogCard extends StatefulWidget {
  final AuctionItem item;

  const CatalogCard({super.key, required this.item});

  @override
  State<CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<CatalogCard> {
  void navigateToSubscriptionAccess(AuctionItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionAccessScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.memory(widget.item.logo),
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
                              widget.item.name,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'sfprodmedium',
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${widget.item.originalPrice.toStringAsFixed(2)} / ${widget.item.formattedFrequency}',
                              style: const TextStyle(
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
                // Start Button
                SizedBox(
                  width: 290,
                  child: PayButton(
                    item: widget.item,
                    onPaid: navigateToSubscriptionAccess,
                    buttonText: 'Subscribe with Crypto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
