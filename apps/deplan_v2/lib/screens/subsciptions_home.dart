import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/months_selector.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/components/subscription_card.dart';
import 'package:deplan/models/payment_info.dart';
import 'package:deplan/models/subscription.dart';
import 'package:deplan/screens/settings_screen.dart';
import 'package:deplan/screens/store_screen.dart';
import 'package:deplan/screens/subscription_details.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      selectedDate.millisecondsSinceEpoch,
    );
    paymentInfoFuture = api.getPaymentInfo(
      selectedDate.millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      showAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 37),
              child: Image.asset('assets/images/DePlan_Logo Black.png'),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreScreen(),
                ),
              );
            },
            icon: SizedBox(
              width: 25,
              height: 25,
              child: Image.asset('assets/icons/apps_icon.png'),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: SizedBox(
              width: 25,
              height: 25,
              child: Image.asset('assets/icons/gear_icon.png'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Time period selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: MonthSelector(
                initialDate: selectedDate,
                onChange: (month, date) {
                  setState(() {
                    selectedDate = date!;
                    subscriptionsFuture = api.listSubscriptions(
                      selectedDate.millisecondsSinceEpoch,
                    );
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Usage of your subscriptions',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w600,
                color: TEXT_MAIN,
              ),
            ),
          ),
          // scrolled list with SubscriptionCard elements
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            final error = snapshot.error as DioException;
                            if (error.type == DioExceptionType.unknown) {
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
                              const SizedBox(height: 50),
                              const Text(
                                'Go to DePlan Store to find products you need',
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: Image.asset(
                                  'assets/icons/apps_icon_white.png',
                                  width: 24,
                                ),
                                label: const Text('DePlan Store'),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const StoreScreen(),
                                    ),
                                  );
                                },
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
                                  selectedDate.day,
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
                                appUrl: subscription.appUrl,
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
                ],
              ),
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

              return buildBottomSheet(
                context,
                snapshot.data!.paymentInfo,
                paymentLink,
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget buildBottomSheet(
  BuildContext context,
  PaymentInfo paymentInfo,
  String? paymentLink,
) {
  final savings =
      (paymentInfo.fullPrice - paymentInfo.youPay).toStringAsFixed(2);

  if (savings == '0.00') {
    return const SizedBox();
  }

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xffffffff),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'You save \$$savings this month',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          // const SizedBox(height: 16),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          //     backgroundColor: Colors.black,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(25.0),
          //     ),
          //   ),
          //   onPressed: () async {
          //     await launchUrl(Uri.parse(paymentLink));
          //   },
          //   child: Row(
          //     mainAxisSize: MainAxisSize.max,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Text(
          //         'Pay ',
          //         style: TextStyle(
          //           fontSize: 18,
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       Text(
          //         '\$${paymentInfo.fullPrice.toStringAsFixed(2)}',
          //         style: const TextStyle(
          //           fontSize: 18,
          //           color: Colors.grey,
          //           decoration: TextDecoration.lineThrough,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         '\$${paymentWithoutComission.toStringAsFixed(2)}',
          //         style: const TextStyle(
          //           fontSize: 18,
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '- Platform fee \$${paymentInfo.comission.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
