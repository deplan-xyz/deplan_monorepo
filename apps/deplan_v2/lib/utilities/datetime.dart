import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

String formatMonthYear(DateTime date) {
  String formattedDate = DateFormat('MMM yy').format(date);
  return formattedDate;
}

class SelectedDate {
  final String month;
  final DateTime date;

  SelectedDate(this.month, this.date);
}

List<SelectedDate> getSurroundingMonths(DateTime selectedDate) {
  List<SelectedDate> surroundingMonths = [];
  for (int i = -2; i <= 1; i++) {
    DateTime newDate =
        Jiffy.parseFromDateTime(selectedDate).add(months: i).dateTime;
    surroundingMonths.add(SelectedDate(formatMonthYear(newDate), newDate));
  }

  return surroundingMonths;
}
