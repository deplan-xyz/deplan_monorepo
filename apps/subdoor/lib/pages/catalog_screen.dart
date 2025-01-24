import 'package:flutter/widgets.dart';
import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/offer_request_form.dart';
import 'package:subdoor/components/payment_confirmation.dart';
import 'package:subdoor/components/search_field.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CatalogScreen extends StatefulWidget {
  final OfferRequestFormData? offerRequestFormData;
  final Function(OfferRequestFormData?)? onOfferRequestUpdate;

  const CatalogScreen({
    super.key,
    this.offerRequestFormData,
    this.onOfferRequestUpdate,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String searchQuery = '';
  bool isOfferRequestLoading = false;

  void _onSearch(String query) async {
    setState(() {
      searchQuery = query;
    });
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

  handleOfferRequest(OfferRequestFormData data) async {
    final confirmed = await showAppBottomSheet(
      context,
      (context) => PaymentConfirmation(
        label: '\$${data.price} USDC /${data.frequency}',
        title:
            'Get $searchQuery ${data.plan} subscription for \$${data.price} USDC',
        description:
            '\$${data.price} USDC will be charged from your Subdoor balance and you’ll get special card to subscribe to $searchQuery',
        onCancel: () => Navigator.pop(context),
        onConfirm: () => Navigator.pop(context, true),
      ),
      backgroundColor: const Color(0xff11243E),
    );

    if (confirmed == null || !confirmed) {
      return;
    }

    try {
      setState(() {
        isOfferRequestLoading = true;
      });
      await auctionApi.request(
        searchQuery,
        data.plan,
        data.price,
        data.frequency,
      );
      widget.onOfferRequestUpdate?.call(null);
      await _displaySuccess(
        'Your card will be issued soon and appear here on Subscripions tab. You will be notified via e-mail. If your card won\'t be issued in 24 hours please reach us at support@deplan.xyz',
      );
      navigateToSubscriptions();
    } on DioException catch (e) {
      _displayError(
        e.response?.data['message'] ?? 'Error paying subscription',
      );
    } catch (e) {
      _displayError('Error paying subscription');
    } finally {
      setState(() {
        isOfferRequestLoading = false;
      });
    }
  }

  void navigateToSubscriptions() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const HomeScreen(initialTab: HomeTab.subscriptions),
      ),
      (route) => false,
    );
  }

  Future _displaySuccess(String message) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request sent'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'sfprodbold',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xff38536B),
    );
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Field
            Center(
              child: SearchField(
                onSearch: _onSearch,
                hintText: 'Enter product name you need',
              ),
            ),
            const SizedBox(height: 30),
            if (searchQuery.isEmpty)
              Center(
                child: SizedBox(
                  width: 310,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textStyle,
                          children: [
                            const TextSpan(
                              text: '1. Type product name in a search bar',
                            ),
                            const TextSpan(text: '\n\n'),
                            const TextSpan(
                              text:
                                  '2. Enter name of plan you need and its price',
                            ),
                            const TextSpan(text: '\n\n'),
                            const TextSpan(
                              text:
                                  '3. Pay with USDC from your Subdoor balance or connected Solana wallet',
                            ),
                            const TextSpan(text: '\n\n'),
                            const TextSpan(
                              text: '4. Get your card',
                            ),
                            const TextSpan(text: '\n\n\n'),
                            TextSpan(
                              style: textStyle.copyWith(
                                fontFamily: 'sfprod',
                                fontWeight: FontWeight.w400,
                              ),
                              text:
                                  'If you have question or issue:\nsupport@deplan.xyz\nor @subdoor on TG',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (searchQuery.isNotEmpty)
              Center(
                child: BodyPadding(
                  child: OfferRequestForm(
                    productName: searchQuery,
                    offerRequestFormData: widget.offerRequestFormData,
                    isLoading: isOfferRequestLoading,
                    onUpdate: (data) {
                      widget.onOfferRequestUpdate?.call(data);
                    },
                    onSubmit: handleOfferRequest,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
