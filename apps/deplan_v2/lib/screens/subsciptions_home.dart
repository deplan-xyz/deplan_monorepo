import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/months_selector.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/components/subscription_card.dart';
import 'package:deplan/constants/routes.dart';
import 'package:deplan/models/payment_info.dart';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/screens/subscription_details.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubsciptionsHome extends StatefulWidget {
  const SubsciptionsHome({super.key});

  @override
  State<SubsciptionsHome> createState() => _SubsciptionsHomeState();
}

class _SubsciptionsHomeState extends State<SubsciptionsHome> {
  DateTime selectedDate = DateTime.now();
  String? paymentLink;

  late Future<List<Subscription>> subscriptionsFuture;
  late Future<PaymentInfoResponse> paymentInfoFuture;

  @override
  void initState() {
    super.initState();

    subscriptionsFuture = api.listSubscriptions(
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1)
          .millisecondsSinceEpoch,
    );
    paymentInfoFuture = api.getPaymentInfo();
    _getPaymentLink();
  }

  _getPaymentLink() async {
    try {
      final link = await api.getPaymentLink();
      setState(() {
        paymentLink = link;
      });
    } on DioException catch (e) {
      print('Get payment link failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Image.asset('assets/images/DePlan_Logo Black.png'),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.pushNamed(context, Routes.settings);
                        }
                      },
                      icon: SizedBox(
                        width: 25,
                        height: 25,
                        child: Image.asset('assets/icons/gear_icon.png'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Time period selector
            SizedBox(
              height: 40,
              width: double.infinity,
              child: MonthSelector(
                initialDate: selectedDate,
                onChange: (month, date) {
                  setState(() {
                    selectedDate = date!;
                    subscriptionsFuture = api.listSubscriptions(
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day + 1,
                      ).millisecondsSinceEpoch,
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Usage of your subscriptions',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w600,
                color: TEXT_MAIN,
              ),
            ),
            // scrolled list with SubscriptionCard elements
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: FutureBuilder<List<Subscription>>(
                      future: subscriptionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          if (snapshot.error is DioException) {
                            final dioError = snapshot.error as DioException;
                            if (dioError.type == DioExceptionType.unknown) {
                              return const Center(
                                child: Text(
                                  'Error: Please check your internet connection',
                                ),
                              );
                            }
                          }
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Column(
                            children: [
                              SubscriptionCard(
                                isEmpty: true,
                                title: 'No subscriptions',
                                planPrice: 0,
                                userPays: 0,
                                usagePercentage: 0,
                                avatar: 'assets/icons/no_subscriptions.png',
                                orgId: 'no_org_id',
                                onTap: (subscription) {},
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "You don't have any subscription yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }

                        final subscriptions = snapshot.data!;
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              subscriptionsFuture = api.listSubscriptions(
                                DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day + 1,
                                ).millisecondsSinceEpoch,
                              );
                            });
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: subscriptions.length,
                            itemBuilder: (context, index) {
                              final subscription = subscriptions[index];
                              return SubscriptionCard(
                                title: subscription.name,
                                planPrice: subscription.planPrice,
                                userPays: subscription.youPay,
                                usagePercentage: subscription.usage,
                                avatar: subscription.logo,
                                orgId: subscription.orgId,
                                onTap: (subscription) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubscriptionDetails(
                                        subscriptionData: subscription,
                                        selectedDate: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  FutureBuilder(
                    future: paymentInfoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('');
                      }

                      if (snapshot.hasError) {
                        return const Text('');
                      }

                      return snapshot.data!.paymentInfo.youPay > 0.5
                          ? buildBottomSheet(
                              context,
                              snapshot.data!.paymentInfo,
                              paymentLink,
                            )
                          : Container();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildBottomSheet(
  BuildContext context,
  PaymentInfo paymentInfo,
  String? paymentLink,
) {
  if (paymentLink == null) {
    return Container();
  }

  final paymentWithoutComission = paymentInfo.youPay - paymentInfo.comission;

  return Container(
    decoration: const BoxDecoration(
      color: Color(0xffffffff),
    ),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'You save \$${(paymentInfo.fullPrice - paymentInfo.youPay).toStringAsFixed(2)} this month',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            onPressed: () async {
              await launchUrl(Uri.parse(paymentLink));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pay ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${paymentInfo.fullPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${paymentWithoutComission.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '+ Platform fee \$${paymentInfo.comission.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
