import 'package:deplan/api/auth.dart';
import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/organization_item_vertical.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/constants/routes.dart';
import 'package:deplan/models/organization.dart';
import 'package:deplan/models/subscription_query_data.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // if user is not authenticated, call Auth.signInWithApple method
  @override
  void initState() {
    super.initState();

    futureOrganization = getOrganizationById();
  }

  Future<Organization> getOrganizationById() async {
    try {
      final organization =
          await api.getOrganizationById(widget.subscriptionQueryData.orgId);
      return organization;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _launchCallbackUrl(String url) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(url));
    }
  }

  _navigateToSubscriptionsHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.subscriptionsHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth.currentUser;
    return ScreenWrapper(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child:
                            Image.asset('assets/images/DePlan_Logo Blue.png'),
                      ),
                    ),
                    const SizedBox(height: 35),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: const Text(
                        'Confirm to subscribe with DePlan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: TEXT_MAIN,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FutureBuilder(
                      future: futureOrganization,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const OrganizationItemVerticalSkeleton();
                        }

                        if (snapshot.hasError) {
                          return const Text('Error fetching organization');
                        }

                        return OrganizationItemVertical(
                          organizationName: snapshot.data!.name,
                          subscriptionPrice:
                              snapshot.data!.settings.pricePerMonth.toString(),
                          organizationWebsite: '',
                          organizationLogoUrl: snapshot.data!.logo,
                        );
                      },
                    ),
                    const SizedBox(height: 35),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const Text(
                        'This price is the cap and you never pay more. You will see how much to pay at the end of the month.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro Display',
                          color: TEXT_SECONDARY,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Expanded(child: SizedBox()),
                    Column(
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
                            onPressed: () async {
                              _launchCallbackUrl(
                                widget.subscriptionQueryData.redirectUrl,
                              );
                              await api.confirmSubscription(
                                widget.subscriptionQueryData.orgId,
                                widget.subscriptionQueryData.data,
                              );
                              _navigateToSubscriptionsHome();
                            },
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
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
