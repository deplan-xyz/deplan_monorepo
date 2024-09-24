import 'package:deplan_subscriptions_client/api/common_api.dart';
import 'package:deplan_subscriptions_client/models/subscription.dart';
import 'package:deplan_subscriptions_client/models/subscription_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DayGrid extends StatelessWidget {
  final DateTime date;
  final Subscription subscriptionData;

  const DayGrid(
      {super.key, required this.date, required this.subscriptionData});

  @override
  Widget build(BuildContext context) {
    int daysInMonth = _getDaysInMonth(date.year, date.month);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<SubscriptionDetailsModel>>(
        future: api.subsciptionDetails(
            subscriptionData.orgId, date.millisecondsSinceEpoch),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            SubscriptionDetailsModel? currentMonthSubscriptions = snapshot.data!
                .where((element) => element.month == date.month)
                .toList()
                ?.first;
            return gridBuilder(
                daysInMonth,
                (BuildContext context, int index) => daysGrid(context, index,
                    usage: currentMonthSubscriptions?.eventsByDay ?? [],
                    currentMonthName:
                        "${DateFormat('MMMM').format(date)} ${index + 1}"));
          }

          if (snapshot.hasError) {
            return gridBuilder(daysInMonth, mockGrid);
          }

          return gridBuilder(daysInMonth, skeletonGrid);
        },
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    // This method calculates the number of days in the given month
    return DateTimeRange(
      start: DateTime(year, month),
      end: DateTime(year, month + 1),
    ).duration.inDays;
  }
}

gridBuilder(int daysInMonth, Function(BuildContext, int) itemBuilder) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7, // 7 days in a week
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: daysInMonth,
    itemBuilder: (BuildContext context, int index) =>
        itemBuilder(context, index),
  );
}

mockGrid(BuildContext context, int index) {
  int dayNumber = index + 1;

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xffE8EAEE), // Gray background color
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        "$dayNumber",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
}

skeletonGrid(BuildContext context, int index) {
  return Skeletonizer(
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xffE8EAEE), // Gray background color
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

daysGrid(BuildContext context, int index,
    {List<Map<String, num>>? usage,
    int? usageIndex,
    String? currentMonthName}) {
  int dayNumber = index + 1;
  Map<String, num> usageData = usage?[index] ?? {};
  final usageColors = [
    const Color(0xffE8EAEE),
    const Color(0xff93E7A2),
    const Color(0xff3EBE5E),
    const Color(0xff2F984A),
    const Color(0xff216435),
  ];
  final usageFontColors = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.white,
    Colors.white,
  ];
  num summaryEventUsage =
      usageData.entries.map((entry) => entry.value).reduce((a, b) => a + b);

  getUsageFontColor(num usage) {
    if (usage == 0) {
      return usageFontColors[0];
    }

    if (usage <= 1) {
      return usageFontColors[1];
    }

    if (usage <= 3) {
      return usageFontColors[2];
    }

    if (usage <= 5) {
      return usageFontColors[3];
    }

    if (usage > 5) {
      return usageFontColors[4];
    }

    return usageFontColors[0];
  }

  getUsageColor(num usage) {
    if (usage == 0) {
      return usageColors[0];
    }

    if (usage <= 1) {
      return usageColors[1];
    }

    if (usage <= 3) {
      return usageColors[2];
    }

    if (usage <= 5) {
      return usageColors[3];
    }

    if (usage > 5) {
      return usageColors[4];
    }

    return usageColors[0];
  }

  return Container(
    decoration: BoxDecoration(
      color: getUsageColor(summaryEventUsage),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Tooltip(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      richMessage: TextSpan(
        text: '$currentMonthName\n',
        children: usageData.entries
            .map((entry) => TextSpan(
                  text: '${entry.key}: ${entry.value} \n',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6D7086),
                  ),
                ))
            .toList(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      child: Center(
        child: Text(dayNumber.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: getUsageFontColor(summaryEventUsage),
            )),
      ),
    ),
  );
}
