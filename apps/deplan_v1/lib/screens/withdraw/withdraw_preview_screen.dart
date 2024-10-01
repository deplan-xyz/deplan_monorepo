import 'package:deplan_v1/api/auth_api.dart';
import 'package:deplan_v1/api/balance_api.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:deplan_core/deplan_core.dart';
import 'package:deplan_v1/screens/withdraw/withdraw_success_screen.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';

class WithdrawPreviewScreen<T extends Widget> extends StatefulWidget {
  final SendMoneyData sendMoneyData;

  const WithdrawPreviewScreen({
    Key? key,
    required this.sendMoneyData,
  }) : super(key: key);

  @override
  State<WithdrawPreviewScreen> createState() => _WithdrawPreviewScreenState();
}

class _WithdrawPreviewScreenState extends State<WithdrawPreviewScreen> {
  bool isLoading = false;

  handleNextPressed(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await balanceApi.withdraw(widget.sendMoneyData);
      final txn = response.data['txn'];
      final res = await authApi.signTxn(txn);
      final signedTxn = res[0];
      await balanceApi.withdraw(widget.sendMoneyData, signedTxn);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WithdrawSuccessScreen(
              sendMoneyData: widget.sendMoneyData,
            ),
          ),
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'];
      _displayError(message ?? 'Something went wrong');
    } catch (e) {
      _displayError('Something went wrong');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  buildAmount(BuildContext context) {
    return Column(
      children: [
        const Text(
          'You Withdraw',
          style: TextStyle(color: COLOR_GRAY),
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.sendMoneyData.amount} DPLN',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  buildInfo(String title, String info, {bool shouldCut = true}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: COLOR_LIGHT_GRAY,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: COLOR_GRAY),
          ),
          const SizedBox(height: 5),
          Text(
            shouldCut ? info.replaceRange(4, 40, '...') : info,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Preview',
      child: Stack(
        children: [
          Positioned.fill(
            child: KeyboardDismissableListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: buildAmount(context),
                ),
                const SizedBox(height: 50),
                AppPadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildInfo(
                        'Withdraw method',
                        widget.sendMoneyData.token?.name ?? '',
                        shouldCut: false,
                      ),
                      const SizedBox(height: 10),
                      buildInfo('To', widget.sendMoneyData.recipient!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 290,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : () => handleNextPressed(context),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const Text('Withdraw'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
