import 'package:flutter/material.dart';
import 'package:deplan_core/deplan_core.dart';
import 'package:iw_app/screens/send_money/send_money_preview_screen.dart';
import 'package:iw_app/widgets/form/input_form.dart';
import 'package:iw_app/widgets/list/keyboard_dismissable_list.dart';
import 'package:iw_app/widgets/scaffold/screen_scaffold.dart';

class SendMoneyAmountScreen<T extends Widget> extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final String senderWallet;
  final SendMoneyData sendMoneyData;
  final Future Function(SendMoneyData) onSendMoney;
  final T Function() originScreenFactory;

  SendMoneyAmountScreen({
    Key? key,
    required this.senderWallet,
    required this.sendMoneyData,
    required this.onSendMoney,
    required this.originScreenFactory,
  }) : super(key: key);

  handleNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendMoneyPreviewScreen(
          sendMoneyData: sendMoneyData,
          senderWallet: senderWallet,
          onSendMoney: onSendMoney,
          originScreenFactory: originScreenFactory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Enter Amount',
      child: Column(
        children: [
          Expanded(
            child: KeyboardDismissableListView(
              children: [
                const SizedBox(height: 40),
                InputForm(
                  formKey: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You Send',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      AppTextFormFieldBordered(
                        suffix: const Text('DPLN'),
                        onChanged: (value) {
                          sendMoneyData.amount = double.tryParse(value);
                        },
                        validator: multiValidate([
                          requiredField('Amount'),
                          numberField('Amount'),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 290,
            child: ElevatedButton(
              onPressed: () => handleNextPressed(context),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
