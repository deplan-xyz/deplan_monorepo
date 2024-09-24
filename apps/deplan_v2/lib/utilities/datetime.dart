import 'package:intl/intl.dart';

String formatMonthYear(DateTime date) {
  String formattedDate = DateFormat("MMM yy").format(date);
  return formattedDate;
}

class SelectedDate {
  final String month;
  final DateTime date;

  SelectedDate(this.month, this.date);
}

List<SelectedDate> getSurroundingMonths(DateTime selectedDate) {
  List<SelectedDate> surroundingMonths = [];
  DateTime currentDate = selectedDate;
  for (int i = -2; i <= 1; i++) {
    DateTime newDate =
        DateTime(currentDate.year, currentDate.month + i, currentDate.day + 1);
    surroundingMonths.add(SelectedDate(formatMonthYear(newDate), newDate));
  }

  return surroundingMonths;
}
