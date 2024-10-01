import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:deplan_core/deplan_core.dart';
import 'package:deplan_v1/screens/withdraw/withdraw_preview_screen.dart';
import 'package:deplan_v1/utils/validation.dart';
import 'package:deplan_v1/widgets/form/input_form.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';

class WithdrawAmountScreen<T extends Widget> extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final SendMoneyData sendMoneyData;

  WithdrawAmountScreen({
    Key? key,
    required this.sendMoneyData,
  }) : super(key: key);

  handleNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WithdrawPreviewScreen(
          sendMoneyData: sendMoneyData,
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
                AppPadding(
                  child: InputForm(
                    formKey: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You Withdraw',
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
