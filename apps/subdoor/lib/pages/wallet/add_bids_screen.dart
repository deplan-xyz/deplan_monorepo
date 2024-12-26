import 'package:subdoor/api/user_api.dart';
import 'package:subdoor/pages/home_screen.dart';
import 'package:subdoor/theme/app_theme.dart';
import 'package:subdoor/widgets/app_scaffold.dart';
import 'package:subdoor/widgets/body_padding.dart';
import 'package:subdoor/widgets/input_form.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AddBidsScreen extends StatefulWidget {
  const AddBidsScreen({super.key});

  @override
  State<AddBidsScreen> createState() => _AddBidsScreenState();
}

class _AddBidsScreenState extends State<AddBidsScreen> {
  final TextEditingController bidsController = TextEditingController(text: '0');
  final TextEditingController dplnsController =
      TextEditingController(text: '0');

  int bids = 0;
  bool isLoading = false;

  void handleGetBidsPressed() async {
    setState(() {
      isLoading = true;
    });

    try {
      await userApi.getBids(bids);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(initialTab: HomeTab.wallet),
          ),
          (route) => false,
        );
      }
    } on DioException catch (e) {
      _displayError(e.response?.data['message'] ?? 'Error getting bids');
    } catch (e) {
      _displayError('Error getting bids');
    } finally {
      setState(() {
        isLoading = false;
      });
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Add Bids'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BodyPadding(
              child: Text(
                'You need to convert DPLNs to get bids to participate in subscriptions actions',
                style: TextStyle(
                  color: Color(0xff87899B),
                ),
              ),
            ),
            const SizedBox(height: 25),
            BodyPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'BIDs you get',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'sfprodbold',
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextFormFieldBordered(
                    controller: bidsController,
                    inputType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    suffix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        'assets/images/bids.png',
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        bids = int.tryParse(value) ?? 0;
                      });
                      dplnsController.text = bids.toString();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            BodyPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'DPLNs you spend',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'sfprodbold',
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextFormFieldBordered(
                    controller: dplnsController,
                    inputType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    suffix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        'assets/images/dpln_coin.png',
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        bids = int.tryParse(value) ?? 0;
                      });
                      bidsController.text = bids.toString();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: bids > 0 && !isLoading ? handleGetBidsPressed : null,
              child: Text('Get $bids bids for $bids DPLNs'),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
