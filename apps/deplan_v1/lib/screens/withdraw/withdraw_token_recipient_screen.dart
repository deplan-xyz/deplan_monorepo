import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:flutter/material.dart';
import 'package:deplan_core/deplan_core.dart';
import 'package:deplan_v1/screens/withdraw/withdraw_amount_screen.dart';
import 'package:deplan_v1/utils/validation.dart';
import 'package:deplan_v1/widgets/form/input_form.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';

class WithdrawTokenRecipientScreen<T extends Widget> extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  late final SendMoneyData data;

  WithdrawTokenRecipientScreen({
    Key? key,
    required SendMoneyToken token,
  }) : super(key: key) {
    data = SendMoneyData(
      token: token,
    );
  }

  handleNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WithdrawAmountScreen(
          sendMoneyData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Recipient',
      child: Column(
        children: [
          Expanded(
            child: KeyboardDismissableListView(
              children: [
                const SizedBox(height: 40),
                AppPadding(
                  child: InputForm(
                    formKey: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextFormField(
                          labelText: 'Enter Recipient’s Solana Wallet',
                          helperText:
                              'Please enter an address of wallet on the Solana blockchain you are goning to send money to.',
                          onChanged: (value) {
                            data.recipient = value;
                          },
                          validator: multiValidate([
                            requiredField('Recipient’s Solana Wallet'),
                            walletAddres(),
                          ]),
                          maxLines: 1,
                        ),
                      ],
                    ),
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
