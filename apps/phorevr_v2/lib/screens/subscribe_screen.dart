import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/app_home.dart';
import 'package:phorevr/app_storage.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentMethod { CreditCard, DePlan, PayPal }

class SubscribeScreen extends StatefulWidget {
  static const String routeName = '/subscribe';

  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final List<Map> paymentMethods = [
    {
      'name': PaymentMethod.CreditCard,
      'title': 'Credit Card',
      'image': 'assets/images/credits.webp',
    },
    {
      'name': PaymentMethod.DePlan,
      'title': 'Pay later with DePlan',
      'image': 'assets/images/deplan.webp',
    },
    {
      'name': PaymentMethod.PayPal,
      'title': 'PayPal',
      'image': 'assets/images/paypal.webp',
    },
  ];
  PaymentMethod? pickedMethod;
  late Future<User?> futureUser;

  @override
  initState() {
    super.initState();
    futureUser = fetchUser();
  }

  Future<User?> fetchUser() async {
    try {
      final response = await authApi.getMe();
      return User.fromJson(response.data['user']);
    } on DioException catch (err) {
      if (err.response?.statusCode == 401) {
        await appStorage.write('redirect_to', '/subscribe');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppHome.routeName,
            (route) => false,
          );
        }
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Widget buildDeplanDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check),
            SizedBox(width: 10),
            Text('Pay for how intensely you will use the app.'),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.check),
            SizedBox(width: 10),
            Text('Pay after a month based on usage.'),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.check),
            SizedBox(width: 10),
            Text('No card. No commitments. No surprises.'),
          ],
        ),
        const Divider(),
        RichText(
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: COLOR_GRAY),
            children: const [
              TextSpan(
                text: 'By continuing I accept the terms for the ',
              ),
              TextSpan(
                style: TextStyle(
                  color: COLOR_ALMOST_BLACK,
                  decoration: TextDecoration.underline,
                ),
                text: 'DePlan Payment Service',
              ),
              TextSpan(
                text: ' and confirm that I have read the',
              ),
              TextSpan(
                style: TextStyle(
                  color: COLOR_ALMOST_BLACK,
                  decoration: TextDecoration.underline,
                ),
                text: ' Privacy Policy.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            try {
              final user = await futureUser;
              final data = const JsonEncoder().convert({'userId': user?.id});
              final url =
                  'https://deplan.app?orgId=66221d9cf2adbf150283556f&redirectUrl=https://sub.phorevr.com&data=$data';
              await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
            } catch (e) {
              print(e);
            }
          },
          child: const Text('Continue with DePlan'),
        ),
      ],
    );
  }

  Widget buildPaymentMethod(BuildContext context, Map method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<PaymentMethod>.adaptive(
          title: Text(method['title']),
          secondary: Image.asset(
            method['image'],
            height: 30,
          ),
          value: method['name'],
          groupValue: pickedMethod,
          onChanged: (PaymentMethod? value) {
            setState(() {
              pickedMethod = value;
            });
          },
        ),
        if (pickedMethod == PaymentMethod.DePlan &&
            method['name'] == PaymentMethod.DePlan)
          Padding(
            padding: const EdgeInsets.all(30),
            child: buildDeplanDescription(context),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        title: const Text('Choose payment method'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          ...paymentMethods.map((m) => buildPaymentMethod(context, m)).toList(),
        ],
      ),
    );
  }
}
