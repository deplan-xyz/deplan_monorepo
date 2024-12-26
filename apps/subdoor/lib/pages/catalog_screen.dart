import 'package:subdoor/api/auction_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/catalog_card.dart';
import 'package:subdoor/components/offer_request_form.dart';
import 'package:subdoor/components/payment_confirmation.dart';
import 'package:subdoor/components/search_field.dart';
import 'package:subdoor/models/auction_item.dart';
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
  late Future<List<AuctionItem>> futureOffers;

  List<AuctionItem> allOffers = [];
  String searchQuery = '';
  bool isOfferRequestLoading = false;

  @override
  void initState() {
    super.initState();
    futureOffers = fetchOffers();
  }

  Future<List<AuctionItem>> fetchOffers() async {
    final response = await auctionApi.getAuctions(
      offerType: OfferType.buy_now.name,
      statuses: [AuctionStatus.active.name],
    );
    allOffers = (response.data['auctionItems'] as List)
        .map((item) => AuctionItem.fromJson(item))
        .toList();
    return allOffers;
  }

  void _onSearch(String query) async {
    final filteredOffers = allOffers
        .where(
          (offer) => offer.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      searchQuery = query;
      futureOffers = Future.value(filteredOffers);
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
        data.link,
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
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Field
            Center(
              child: SearchField(onSearch: _onSearch),
            ),
            const SizedBox(height: 30),
            // Cards
            FutureBuilder<List<AuctionItem>>(
              future: futureOffers,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching offers: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
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
                  );
                }
                return Column(
                  children: snapshot.data!
                      .map(
                        (item) => Column(
                          children: [
                            CatalogCard(item: item),
                            const SizedBox(height: 30),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
