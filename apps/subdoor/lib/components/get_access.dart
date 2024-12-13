import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/material.dart';

class GetAccess extends StatelessWidget {
  final AuctionItem item;

  const GetAccess({super.key, required this.item});

  Widget buildText(String text, String text2) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'sfprod',
            fontSize: 18,
            color: Color(0xff87899B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          text2,
          style: const TextStyle(
            fontFamily: 'sfprod',
            fontSize: 18,
            color: Color(0xff11243E),
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            'assets/images/copy.png',
            width: 20,
            height: 20,
          ),
          constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
          padding: const EdgeInsets.all(0.0),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BodyPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Subscribe to Notion with\nthis card',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'sfprodbold',
              fontSize: 30,
              height: 1.1,
              color: Color(0xff000000),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText('Card: ', '4865 5500 3655 5068'),
              buildText('Exp: ', '11/27'),
              buildText('CVC: ', '220'),
              buildText('Billing Address: ', '132 Carr Ave'),
              buildText('City: ', 'Keansburg'),
              buildText('State: ', 'NJ'),
              buildText('Zip: ', '07734'),
              const SizedBox(
                height: 25,
              ),
              buildText('', '132 Carr Ave, Keansburg, 07734, NJ'),
            ],
          ),
          const SizedBox(
            height: 45,
          ),
          const Text(
            'This card works only with Notion\nand only for \$12/mo plan. In any\nother case card will be blocked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'sfprodbold',
              fontSize: 22,
              color: Color(0xffFF0000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
