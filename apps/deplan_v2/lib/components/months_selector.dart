import 'package:deplan_subscriptions_client/utilities/datetime.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MonthSelector extends StatefulWidget {
  final DateTime initialDate;
  // final ValueChanged<String> onChange;
  // on change function that received 2 parameters - String and datetime
  final Function(String, DateTime?) onChange;

  const MonthSelector({
    super.key,
    required this.initialDate,
    required this.onChange,
  });

  @override
  MonthSelectorState createState() => MonthSelectorState();
}

class MonthSelectorState extends State<MonthSelector> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    List<SelectedDate> months =
        getSurroundingMonths(selectedDate ?? DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 50, // Set a fixed height for the ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index].month;
                final isSelected =
                    months[index].date.month == selectedDate!.month &&
                        months[index].date.year == selectedDate!.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = months[index].date;
                    });
                    widget.onChange(month, selectedDate);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        month,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            showMonthPicker(
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime(DateTime.now().year + 10),
              context: context,
              initialDate: selectedDate,
            ).then((date) {
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            });
          },
          icon: SizedBox(
              width: 25,
              height: 25,
              child: Image.asset('assets/icons/calendar-icon.png')),
        ),
      ],
    );
  }
}
