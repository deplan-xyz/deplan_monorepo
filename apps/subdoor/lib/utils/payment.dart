import 'package:jiffy/jiffy.dart';
import 'package:subdoor/models/auction_item.dart';

DateTime calculateNextPaymentAt(
  DateTime subscribedAt,
  SubscriptionFrequency frequency,
) {
  final Jiffy now = Jiffy.now();
  final Jiffy subscribedAtJiffy =
      Jiffy.parseFromDateTime(subscribedAt).toLocal();
  Jiffy nextPaymentAt = subscribedAtJiffy;

  if (frequency == SubscriptionFrequency.weekly) {
    nextPaymentAt = calculateWeekly(subscribedAtJiffy, now);
  } else if (frequency == SubscriptionFrequency.monthly) {
    nextPaymentAt = calculateMonthly(subscribedAtJiffy, now);
  } else if (frequency == SubscriptionFrequency.three_months) {
    nextPaymentAt = calculateMonths(subscribedAtJiffy, now, 3);
  } else if (frequency == SubscriptionFrequency.six_months) {
    nextPaymentAt = calculateMonths(subscribedAtJiffy, now, 6);
  } else {
    nextPaymentAt = calculateYearly(subscribedAtJiffy, now);
  }

  return nextPaymentAt.dateTime;
}

Jiffy calculateWeekly(Jiffy subscribedAtJiffy, Jiffy now) {
  num diff = now
      .startOf(Unit.day)
      .diff(subscribedAtJiffy.startOf(Unit.day), unit: Unit.week);

  if (now.date >= subscribedAtJiffy.add(weeks: diff.toInt()).date) {
    diff += 1;
  }

  return subscribedAtJiffy.add(weeks: diff.toInt());
}

Jiffy calculateMonthly(Jiffy subscribedAtJiffy, Jiffy now) {
  num diff = now
      .startOf(Unit.month)
      .diff(subscribedAtJiffy.startOf(Unit.month), unit: Unit.month);
  bool isLastDayOfMonth = now.daysInMonth == now.date;

  if (now.date >= subscribedAtJiffy.date || isLastDayOfMonth) {
    diff += 1;
  }

  return subscribedAtJiffy.add(months: diff.toInt());
}

Jiffy calculateMonths(Jiffy subscribedAtJiffy, Jiffy now, num months) {
  num diff = now
      .startOf(Unit.month)
      .diff(subscribedAtJiffy.startOf(Unit.month), unit: Unit.month);
  bool isLastDayOfMonth = now.daysInMonth == now.date;

  diff = (diff / months).ceil() * months;

  Jiffy nextPaymentAt = subscribedAtJiffy.add(months: diff.toInt());

  if (now.month == nextPaymentAt.month &&
      (now.date >= nextPaymentAt.date || isLastDayOfMonth)) {
    diff += months;
  }

  nextPaymentAt = subscribedAtJiffy.add(months: diff.toInt());

  return nextPaymentAt;
}

Jiffy calculateYearly(Jiffy subscribedAtJiffy, Jiffy now) {
  num diff = now
      .startOf(Unit.year)
      .diff(subscribedAtJiffy.startOf(Unit.year), unit: Unit.year);

  if (now
          .format(pattern: 'MM-dd')
          .compareTo(subscribedAtJiffy.format(pattern: 'MM-dd')) >=
      0) {
    diff += 1;
  }

  return subscribedAtJiffy.add(years: diff.toInt());
}
