import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/payment_confirmation.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PayButton extends StatefulWidget {
  final AuctionItem item;
  final Function(AuctionItem) onPaid;
  final String? buttonText;

  const PayButton({
    super.key,
    required this.item,
    required this.onPaid,
    this.buttonText,
  });

  @override
  State<PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<PayButton> {
  bool isLoading = false;

  void _handlePayPressed() async {
    final price = widget.item.offerType == OfferType.auction
        ? widget.item.currentPrice
        : widget.item.originalPrice;
    final confirmed = await showAppBottomSheet(
      context,
      (context) => PaymentConfirmation(
        logo: widget.item.logo,
        label:
            '\$$price USDC /${AuctionItem.formatFrequencyShort(widget.item.subscriptionFrequency)}',
        title: 'Get ${widget.item.name} subscription for \$$price USDC',
        description:
            '\$$price USDC will be charged from your Subdoor balance and you’ll get special card to subscribe to ${widget.item.name}',
        onCancel: () => Navigator.pop(context),
        onConfirm: () => Navigator.pop(context, true),
      ),
      backgroundColor: const Color(0xff11243E),
    );
    if (confirmed != null && confirmed) {
      setState(() {
        isLoading = true;
      });
      try {
        final response = await userApi.paySubscription(widget.item.id);
        widget.onPaid(AuctionItem.fromJson(response.data['subscription']));
      } on DioException catch (e) {
        _displayError(
          e.response?.data['message'] ?? 'Error paying subscription',
        );
      } catch (e) {
        _displayError('Error paying subscription');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handlePayPressed,
      child: isLoading
          ? const Text('PROCESSING...')
          : Text(widget.buttonText ?? 'PAY \$${widget.item.currentPrice}'),
    );
  }
}
