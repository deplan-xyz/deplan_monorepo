import 'package:deplan_core/deplan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iw_app/models/offer_model.dart';
import 'package:iw_app/models/organization_model.dart';
import 'package:iw_app/screens/offer/offer_preview_screen.dart';
import 'package:iw_app/theme/app_theme.dart';
import 'package:iw_app/utils/input_formatters.dart';
import 'package:iw_app/widgets/form/input_form.dart';
import 'package:iw_app/widgets/list/keyboard_dismissable_list.dart';
import 'package:iw_app/widgets/scaffold/screen_scaffold.dart';

class OfferInvestorScreen extends StatefulWidget {
  final Organization organization;

  const OfferInvestorScreen({
    Key? key,
    required this.organization,
  }) : super(key: key);

  @override
  State<OfferInvestorScreen> createState() => _OfferInvestorScreenState();
}

class _OfferInvestorScreenState extends State<OfferInvestorScreen> {
  final formKey = GlobalKey<FormState>();
  String? equityError;

  Offer offer = Offer(
    type: OfferType.Investor,
    investorSettings: OfferInvestorSettings(),
    availableInvestment: OfferInvestorSettings(),
  );

  TextEditingController minimalInvestmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    minimalInvestmentController.text =
        offer.investorSettings!.minimalInvestment.toString();
  }

  buildForm() {
    return InputForm(
      formKey: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is the deal?',
            style: TextStyle(color: COLOR_GRAY),
          ),
          const SizedBox(height: 25),
          const Text(
            'Raising',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          AppTextFormFieldBordered(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              commaSeparatedNumberFormatter,
            ],
            autofocus: true,
            prefix: const Text('\$'),
            validator: multiValidate([
              requiredField('Raising'),
              numberField('Raising'),
            ]),
            onChanged: (value) {
              final val = value.replaceAll(',', '');
              if (double.tryParse(val) != null) {
                offer.investorSettings!.amount = double.tryParse(val);
              }
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Equity Allocation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          AppTextFormFieldBordered(
            errorText: equityError,
            prefix: const Text('%'),
            validator: multiValidate([
              requiredField('Equity Allocation'),
              numberField('Equity Allocation'),
              max(100),
            ]),
            onChanged: (value) {
              offer.investorSettings!.equity = double.tryParse(value);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Minimal Investment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          AppTextFormFieldBordered(
            prefix: const Text('\$'),
            controller: minimalInvestmentController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              commaSeparatedNumberFormatter,
            ],
            inputType: TextInputType.number,
            validator: multiValidate([
              requiredField('Minimal Investment'),
              numberField('Minimal Investment'),
            ]),
            onChanged: (value) {
              final val = value.replaceAll(',', '');
              if (double.tryParse(val) != null) {
                offer.investorSettings!.minimalInvestment =
                    double.tryParse(val);
              }
            },
          ),
        ],
      ),
    );
  }

  handleNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      final equityError = await Navigator.of(context).push<String?>(
        MaterialPageRoute(
          builder: (_) => OfferPreviewScreen(
            organization: widget.organization,
            offer: offer,
          ),
        ),
      );
      if (equityError != null) {
        setState(() {
          this.equityError = equityError;
        });
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Offer for Investors',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: KeyboardDismissableListView(
              children: [
                buildForm(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 290,
              child: ElevatedButton(
                onPressed: () => handleNextPressed(context),
                child: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
