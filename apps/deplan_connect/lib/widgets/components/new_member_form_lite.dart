import 'package:deplan_core/deplan_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iw_app/l10n/generated/app_localizations.dart';
import 'package:iw_app/models/organization_member_model.dart';
import 'package:iw_app/screens/generic_screen.dart';
import 'package:iw_app/theme/app_theme.dart';
import 'package:iw_app/widgets/components/app_select.dart';
import 'package:iw_app/widgets/components/bottom_sheet_info.dart';
import 'package:iw_app/widgets/form/input_form.dart';
import 'package:iw_app/widgets/form/modal_form_field.dart';

class NewMemberFormLite extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final OrganizationMember member;
  final String title;
  final timeframeOptions = PeriodType.values
      .map((e) => ({'value': e, 'title': e.name.toLowerCase()}))
      .toList();

  NewMemberFormLite({
    Key? key,
    required this.formKey,
    required this.member,
    required this.title,
  }) : super(key: key);

  @override
  State<NewMemberFormLite> createState() => _NewMemberFormLiteState();
}

class _NewMemberFormLiteState extends State<NewMemberFormLite> {
  final equityPeriodController = TextEditingController();
  final compensationPeriodController = TextEditingController();

  bool isWithEquity = false;
  bool isMonthlyCompensated = false;

  OrganizationMember get member => widget.member;
  String get title => widget.title;

  onOccupationChanged(String value) {
    setState(() {
      member.occupation = value;
    });
  }

  onMonthlyCompensationChanged(String value) {
    setState(() {
      member.compensation?.amount = double.tryParse(value) ?? 0;
    });
  }

  onEquityChanged(String value) {
    setState(() {
      member.equityAmount = double.tryParse(value) ?? 0;
    });
  }

  onEquityPeriodChanged(String value) {
    setState(() {
      member.equityPeriod?.value = double.tryParse(value) ?? 0;
    });
  }

  onCompensationPeriodChanged(String value) {
    setState(() {
      member.compensation?.period?.value = double.tryParse(value) ?? 0;
    });
  }

  onEquityTimeframeChanged(Map? value) {
    setState(() {
      member.equityPeriod?.timeframe = value?['value'];
    });
  }

  onCompensationTimeframeChanged(Map? value) {
    setState(() {
      member.compensation?.period?.timeframe = value?['value'];
    });
  }

  onIsMonthlyCompensatedChanged(bool value) {
    setState(() {
      isMonthlyCompensated = value;
      if (value) {
        member.compensation = Compensation(type: CompensationType.PerMonth);
      } else {
        member.compensation = null;
      }
    });
  }

  onAutoContributionChanged(bool value) {
    setState(() {
      member.isAutoContributing = value;
    });
  }

  onIsWithEquityChanged(bool value) {
    setState(() {
      isWithEquity = value;
      if (value) {
        member.equityType = EquityType.Immediately;
      } else {
        member.equityAmount = null;
        member.equityType = null;
      }
    });
  }

  buildEquitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Give Equity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CupertinoSwitch(
              value: isWithEquity,
              activeColor: COLOR_GREEN,
              onChanged: (bool? value) {
                onIsWithEquityChanged(value!);
              },
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              const Text('Immediately'),
              IconButton(
                onPressed: () {
                  showBottomInfoSheet(
                    context,
                    title: 'Give Equity Immediately',
                    description:
                        'A member will get allocated percent of equity right after signing an offer',
                  );
                },
                icon: const Icon(Icons.info_outline_rounded),
                iconSize: 16,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: COLOR_GRAY,
              ),
            ],
          ),
          minLeadingWidth: 0,
          leading: Radio(
            activeColor: Colors.black,
            value: EquityType.Immediately,
            groupValue: member.equityType,
            onChanged: isWithEquity
                ? (EquityType? type) {
                    setState(() {
                      equityPeriodController.text = '';
                      member.equityType = type;
                      member.equityPeriod = null;
                    });
                  }
                : null,
          ),
        ),
        AppTextFormFieldBordered(
          enabled: isWithEquity && member.equityType == EquityType.Immediately,
          prefix: const Text('%'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: isWithEquity && member.equityType == EquityType.Immediately
              ? multiValidate([
                  requiredField('Equity'),
                  numberField('Equity'),
                  max(100),
                  min(0),
                ])
              : (_) => null,
          onChanged: onEquityChanged,
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              const Text(
                'During the period',
                style: TextStyle(color: COLOR_GRAY2),
              ),
              IconButton(
                onPressed: () {
                  showBottomInfoSheet(
                    context,
                    title: 'Give Equity During the Period',
                    description:
                        'Percent of equity will be broken down equally into amount of days. Every day during the period a member will get a part of allocated equity. For example: 10% during 100 days. It means that a member will get 0,1% every day during 100 days.',
                  );
                },
                icon: const Icon(Icons.info_outline_rounded),
                iconSize: 16,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: COLOR_GRAY2,
              ),
              const Spacer(),
              const Text(
                'Coming soon',
                style:
                    TextStyle(color: COLOR_BLUE, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          minLeadingWidth: 0,
          leading: Radio(
            activeColor: Colors.black,
            value: EquityType.DuringPeriod,
            groupValue: member.equityType,

            // replace null with handler after "Coming soon" is removed
            onChanged: null,
            // onChanged: isWithEquity
            //     ? (EquityType? type) {
            //         setState(() {
            //           equityPeriodController.text = '';
            //           member.equity?.type = type;
            //           member.equity?.period =
            //               Period(timeframe: PeriodType.Months);
            //         });
            //       }
            //     : null,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFormFieldBordered(
                enabled: isWithEquity &&
                    member.equityType == EquityType.DuringPeriod,
                prefix: const Text('%'),
                inputType: const TextInputType.numberWithOptions(decimal: true),
                validator:
                    isWithEquity && member.equityType == EquityType.DuringPeriod
                        ? multiValidate([
                            requiredField('Equity'),
                            numberField('Equity'),
                            max(100),
                            min(0),
                          ])
                        : (_) => null,
                onChanged: onEquityChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextFormFieldBordered(
                controller: equityPeriodController,
                enabled: isWithEquity &&
                    member.equityType == EquityType.DuringPeriod,
                labelText: 'period',
                validator:
                    isWithEquity && member.equityType == EquityType.DuringPeriod
                        ? multiValidate([
                            requiredField('Period'),
                            numberField('Period'),
                          ])
                        : (_) => null,
                onChanged: onEquityPeriodChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ModalFormField<Map>(
                enabled: isWithEquity &&
                    member.equityType == EquityType.DuringPeriod,
                screenFactory: (value) => GenericScreen(
                  title: 'Select',
                  child: AppSelect(
                    value,
                    options: widget.timeframeOptions,
                    onChanged: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                ),
                valueToText: (value) => value?['title'],
                labelText: 'timeframe',
                onChanged: onEquityTimeframeChanged,
                initialValue: member.equityPeriod != null
                    ? {
                        'title':
                            member.equityPeriod?.timeframe?.name.toLowerCase(),
                        'value': member.equityPeriod?.timeframe,
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildForm(BuildContext context) {
    return InputForm(
      formKey: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: COLOR_GRAY),
          ),
          const SizedBox(height: 40),
          AppTextFormField(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelText: AppLocalizations.of(context)!
                .createOrgMemberScreen_occupationLabel,
            validator: requiredField(
              AppLocalizations.of(context)!
                  .createOrgMemberScreen_occupationErrorLabel,
            ),
            onChanged: onOccupationChanged,
          ),
          const SizedBox(height: 30),
          buildEquitySection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildForm(context);
  }
}
