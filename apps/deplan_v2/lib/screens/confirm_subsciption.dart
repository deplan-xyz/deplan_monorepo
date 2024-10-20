import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:deplan/api/auth.dart';
import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/components/ui_notifications.dart';
import 'package:deplan/models/organization.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmSubsciption extends StatefulWidget {
  final SubscriptionQueryData subscriptionQueryData;

  const ConfirmSubsciption({
    super.key,
    required this.subscriptionQueryData,
  });

  @override
  State<ConfirmSubsciption> createState() => _ConfirmSubsciptionState();
}

class _ConfirmSubsciptionState extends State<ConfirmSubsciption> {
  late Future<Organization> futureOrganization;
  late Future<List<String>?> futureOrgEvents;
  late Map<String, TextEditingController> _eventControllers;

  Map<String, dynamic>? eventsDemo;

  final ValueNotifier<double> _valueNotifier = ValueNotifier(37.0);

  @override
  void initState() {
    super.initState();

    futureOrganization = getOrganizationById();
    futureOrgEvents = getOrgEvents();
  }

  double get refund => eventsDemo?['planPrice'] - eventsDemo?['youPay'];

  Future<Organization> getOrganizationById() async {
    try {
      final organization =
          await api.getOrganizationById(widget.subscriptionQueryData.orgId);
      return organization;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>?> getOrgEvents() async {
    try {
      final response =
          await api.getOrgEvents(widget.subscriptionQueryData.orgId);
      final eventTypes = List<String>.from(response.data['events']);
      _eventControllers = Map.fromEntries(
        eventTypes
            .map((type) => MapEntry(type, TextEditingController(text: '0'))),
      );
      fetchEventsDemo(eventTypes);
      return eventTypes;
    } on DioException catch (e) {
      final message = e.response?.data['message'];
      if (mounted) {
        showSnackBar(context, message);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future fetchEventsDemo(List<String> eventTypes) async {
    try {
      final data = {
        'events': eventTypes
            .map(
              (type) => ({
                'type': type,
                'amount': int.parse(_eventControllers[type]!.text),
              }),
            )
            .toList(),
      };
      final response = await api.getEventsDemo(
        widget.subscriptionQueryData.orgId,
        data,
      );
      setState(() {
        eventsDemo = response.data['result'];
      });
    } on DioException catch (e) {
      final message = e.response?.data['message'];
      if (mounted) {
        showSnackBar(context, message);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _confirmSubscription() async {
    try {
      final paymentUrl = await api.confirmSubscription(
        widget.subscriptionQueryData.orgId,
        widget.subscriptionQueryData.data,
      );
      await _launchPaymentUrl(paymentUrl);
    } on DioException catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          e.response?.data['message'] ?? 'Error confirming subscription',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
    }
  }

  Widget buildEventType(
    List<String> eventTypes,
    int index,
    TextStyle bodyTextStyle,
  ) {
    final controller = _eventControllers[eventTypes[index]]!;
    return Row(
      children: [
        Text(eventTypes[index], style: bodyTextStyle),
        const Expanded(child: SizedBox()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final currentValue = int.parse(controller.text);
                if (currentValue > 0) {
                  controller.text = (currentValue - 1).toString();
                  fetchEventsDemo(eventTypes);
                }
              },
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 40,
              child: TextField(
                controller: controller,
                enabled: false,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                controller.text = (int.parse(controller.text) + 1).toString();
                fetchEventsDemo(eventTypes);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildEstimatedUsage(Organization organization) {
    const titleStyle = TextStyle(
      fontSize: 22,
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600,
      color: Color(0xff11243E),
    );
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated price',
              style: titleStyle,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan price',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${organization.settings.pricePerMonth}',
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xff11243E).withOpacity(0.4),
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You pay',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${eventsDemo?['youPay']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'SF Pro Display',
                        color: TEXT_MAIN,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Expanded(child: SizedBox()),
        SizedBox(
          width: 70,
          height: 70,
          child: DashedCircularProgressBar.aspectRatio(
            aspectRatio: 1, // width ÷ height
            valueNotifier: _valueNotifier,
            progress:
                double.parse(eventsDemo?['usage']?.toStringAsFixed(1) ?? '0.0'),
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
                    '${(eventsDemo?['usage'] as double).toStringAsFixed(1)}%',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth.currentUser;
    return ScreenWrapper(
      child: FutureBuilder(
        future: Future.wait([futureOrganization, futureOrgEvents]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching organization');
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final organization = snapshot.data![0] as Organization;
          final eventTypes = snapshot.data![1] as List<String>? ?? [];
          const bodyTextStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Display',
            color: TEXT_SECONDARY,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Image.asset(
                                'assets/images/DePlan_Logo_square.png',
                              ),
                            ),
                          ),
                          ...List.generate(
                            5,
                            (_) => SizedBox(
                              width: 9,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade700,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: FadeInImage(
                                placeholder: MemoryImage(kTransparentImage),
                                image: NetworkImage(organization.logo),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Center(
                        child: Text(
                          'Subscribe with DePlan to\npay for how much you actually use\n${organization.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: TEXT_MAIN,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Check how intensity of the usage is calculated',
                          style: bodyTextStyle,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ...List.generate(
                              eventTypes.length,
                              (index) => Column(
                                children: [
                                  buildEventType(
                                    eventTypes,
                                    index,
                                    bodyTextStyle,
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      if (eventsDemo != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: buildEstimatedUsage(organization),
                        ),
                      if (eventsDemo == null)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      const SizedBox(height: 35),
                      if (eventsDemo != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Based on such usage you will get \$${refund.toStringAsFixed(2)} refund to your card at the end of the month',
                            style: bodyTextStyle,
                          ),
                        ),
                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your DePlan account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'SF Pro Display',
                        color: TEXT_SECONDARY,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro Display',
                        color: COLOR_BLACK,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _confirmSubscription,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Confirm and Subscribe'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
