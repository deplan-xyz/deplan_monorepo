import 'dart:collection';

import 'package:subdoor/models/auction_item.dart';
import 'package:subdoor/utils/validation.dart';
import 'package:subdoor/widgets/input_form.dart';
import 'package:flutter/material.dart';

class OfferRequestFormData {
  final String link;
  final String plan;
  final double price;
  final String frequency;

  OfferRequestFormData({
    required this.link,
    required this.plan,
    required this.price,
    required this.frequency,
  });
}

class OfferRequestForm extends StatefulWidget {
  final String productName;
  final OfferRequestFormData? offerRequestFormData;
  final Function(OfferRequestFormData) onSubmit;
  final Function(OfferRequestFormData)? onUpdate;
  final bool isLoading;

  const OfferRequestForm({
    super.key,
    required this.productName,
    required this.onSubmit,
    required this.isLoading,
    this.offerRequestFormData,
    this.onUpdate,
  });

  @override
  State<OfferRequestForm> createState() => _OfferRequestFormState();
}

class _OfferRequestFormState extends State<OfferRequestForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController linkController;
  late final TextEditingController planController;
  late final TextEditingController priceController;
  late String frequency;
  late String plan;

  @override
  void initState() {
    super.initState();
    linkController =
        TextEditingController(text: widget.offerRequestFormData?.link);
    planController =
        TextEditingController(text: widget.offerRequestFormData?.plan);
    priceController = TextEditingController(
      text: widget.offerRequestFormData?.price.toString(),
    );
    frequency = widget.offerRequestFormData?.frequency ??
        SubscriptionFrequency.monthly.name;
    plan = widget.offerRequestFormData?.plan ?? '';
  }

  double get price =>
      double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;

  OfferRequestFormData get formData => OfferRequestFormData(
        link: linkController.text,
        plan: planController.text,
        price: price,
        frequency: frequency,
      );

  void handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    return InputForm(
      formKey: _formKey,
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Subscribe to ',
                ),
                TextSpan(
                  text: widget.productName,
                  style: const TextStyle(
                    fontFamily: 'sfprodbold',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (plan.isNotEmpty)
                  TextSpan(
                    text: ' $plan',
                    style: const TextStyle(
                      fontFamily: 'sfprodbold',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const TextSpan(
                  text: ' with crypto',
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 17,
          ),
          AppTextFormFieldBordered(
            inputType: TextInputType.url,
            textInputAction: TextInputAction.next,
            controller: linkController,
            labelText: 'Insert pricing page link here',
            onChanged: (value) {
              widget.onUpdate?.call(formData);
            },
            validator: requiredField('Link'),
          ),
          const SizedBox(
            height: 30,
          ),
          AppTextFormFieldBordered(
            inputType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: planController,
            labelText: 'Enter plan name here',
            onChanged: (value) {
              widget.onUpdate?.call(formData);
              setState(() {
                plan = value;
              });
            },
            validator: requiredField('Plan name'),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextFormFieldBordered(
                  inputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  controller: priceController,
                  labelText: 'Enter plan price in \$USD',
                  validator: multiValidate(
                    [
                      requiredField('Price'),
                      numberField('Price'),
                    ],
                  ),
                  onChanged: (value) {
                    widget.onUpdate?.call(formData);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              DropdownMenu<String>(
                initialSelection: frequency,
                onSelected: (String? value) {
                  setState(() {
                    frequency = value!;
                  });
                  widget.onUpdate?.call(formData);
                },
                inputDecorationTheme: InputDecorationTheme(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xffFFFFFF),
                  ),
                ),
                dropdownMenuEntries:
                    UnmodifiableListView<DropdownMenuEntry<String>>(
                  SubscriptionFrequency.values.map<DropdownMenuEntry<String>>(
                    (SubscriptionFrequency value) => DropdownMenuEntry<String>(
                      value: value.name,
                      label: AuctionItem.formatFrequencyLong(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 49,
          ),
          ElevatedButton(
            onPressed: !widget.isLoading ? handleSubmit : null,
            child: SizedBox(
              width: 287,
              child: Text(
                widget.isLoading ? 'Processing...' : 'Subscribe with crypto',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
