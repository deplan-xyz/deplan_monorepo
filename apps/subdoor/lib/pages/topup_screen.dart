import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/components/bottom_sheet.dart';
import 'package:subdoor/components/payment_confirmation.dart';
import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:subdoor/widgets/input_form.dart';

class TopupScreen extends StatefulWidget {
  final AuctionItem item;

  const TopupScreen({super.key, required this.item});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  late String amount;

  bool isLoading = false;

  num get amountNum => double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;

  bool get isValid {
    return amount.isNotEmpty && amountNum > 0;
  }

  @override
  void initState() {
    super.initState();
    amount = widget.item.originalPrice.toString();
  }

  void navigateToSubscriptions() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(
            initialTab: HomeTab.subscriptions,
          ),
        ),
        (route) => false,
      );
    }
  }

  void handleSubmit() async {
    if (!isValid) {
      return;
    }

    final confirmed = await showAppBottomSheet(
      context,
      (context) => PaymentConfirmation(
        logo: widget.item.logo,
        label:
            '\$${widget.item.originalPrice} USDC /${AuctionItem.formatFrequencyShort(widget.item.subscriptionFrequency)}',
        title: 'Top-Up ${widget.item.name} card for \$$amountNum USDC',
        description:
            '\$$amountNum USDC will be charged from your Subdoor balance',
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
        await userApi.topUpSubscription(widget.item.id, amountNum);
        _displaySuccess('Card top-up successful');
        navigateToSubscriptions();
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

  void _displaySuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Top-Up'),
      ),
      body: SingleChildScrollView(
        child: BodyPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Top-up your ${widget.item.name} card for',
                style: const TextStyle(
                  fontFamily: 'sfprodmedium',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff87899B),
                ),
              ),
              const SizedBox(height: 40),
              AppTextFormFieldBordered(
                initialValue: amount,
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                labelText: 'Enter amount',
                onChanged: (value) {
                  setState(() {
                    amount = value;
                  });
                },
              ),
              const SizedBox(height: 100),
              Center(
                child: SizedBox(
                  width: 290,
                  child: ElevatedButton(
                    onPressed: !isValid || isLoading ? null : handleSubmit,
                    child: Text(
                      isLoading ? 'Processing...' : 'Top-up \$$amountNum USDC',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
