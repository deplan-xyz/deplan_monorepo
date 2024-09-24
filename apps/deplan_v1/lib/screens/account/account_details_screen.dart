import 'package:deplan/models/txn_history_item.dart';
import 'package:deplan/models/user_balance.dart';
import 'package:deplan/screens/app_iframe_screen.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:deplan/utils/datetime.dart';
import 'package:deplan/utils/numbers.dart';
import 'package:deplan/widgets/list/generic_list_tile.dart';
import 'package:deplan/widgets/view/app_padding.dart';
import 'package:flutter/material.dart';
import 'package:deplan/api/auth_api.dart';
import 'package:deplan/api/balance_api.dart';
import 'package:deplan/models/user.dart';
import 'package:deplan/screens/account/components/account_header.dart';
import 'package:deplan/widgets/view/screen_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late Future<User?> futureUser;
  late Future<UserBalance?> futureBalance;
  late Future<List<TxnHistoryItem>?> futureHistory;

  @override
  void initState() {
    futureUser = fetchUser();
    futureBalance = fetchBalance();
    futureHistory = fetchHistory();
    super.initState();
  }

  Future<User?> fetchUser() async {
    try {
      final response = await authApi.getMe();
      return User.fromJson(response.data['user']);
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<UserBalance?> fetchBalance() async {
    final response = await balanceApi.getBalance();
    return UserBalance.fromJson(response.data);
  }

  Future<List<TxnHistoryItem>?> fetchHistory() async {
    final response = await balanceApi.getHistory();
    return (response.data as List)
        .map((json) => TxnHistoryItem.fromJson(json))
        .toList();
  }

  Future onRefresh() {
    setState(() {
      futureUser = fetchUser();
      futureBalance = fetchBalance();
    });
    return Future.wait([futureUser, futureBalance]);
  }

  navigateToExplorer(String hash) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AppIframeScreen('https://solscan.io/tx/$hash'),
      ),
    );
  }

  buildReceiptItem(TxnHistoryItem item, TxnHistoryItem? prevItem) {
    final duration =
        '${double.tryParse(item.title ?? '')?.toStringAsFixed(3)} min';
    final price =
        '\$${double.tryParse(item.subtitle ?? '')?.toStringAsFixed(3)} / hr';
    final amount =
        '- ${trimZeros(double.tryParse(item.title2 ?? '') ?? 0)} DPLN';
    final destination = 'sent to ${item.subtitle2?.replaceRange(4, 40, '...')}';
    final processedAt = item.processedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(item.processedAt!)
        : DateTime.now();
    final processedAtStr = getFormattedDate(processedAt);
    bool shouldDisplayDate = true;
    if (prevItem != null) {
      final prevProcessedAt = prevItem.processedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(prevItem.processedAt!)
          : DateTime.now();
      final prevProcessedAtStr = getFormattedDate(prevProcessedAt);
      shouldDisplayDate = prevProcessedAtStr != processedAtStr;
    }
    return Column(
      children: [
        if (shouldDisplayDate)
          AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processedAtStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: COLOR_GRAY,
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        InkWell(
          onTap: () => navigateToExplorer(item.hash ?? ''),
          child: AppPadding(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: GenericListTile(
                showMiniIcon: false,
                image: item.image != null ? Image.network(item.image!) : null,
                title: duration,
                subtitle: price,
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      destination,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: COLOR_GRAY,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildDepositItem(TxnHistoryItem item, TxnHistoryItem? prevItem) {
    final amount = '+ ${double.tryParse(item.title2 ?? '')} DPLN';
    final processedAt = item.processedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(item.processedAt!)
        : DateTime.now();
    final processedAtStr = getFormattedDate(processedAt);
    bool shouldDisplayDate = true;
    if (prevItem != null) {
      final prevProcessedAt = prevItem.processedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(prevItem.processedAt!)
          : DateTime.now();
      final prevProcessedAtStr = getFormattedDate(prevProcessedAt);
      shouldDisplayDate = prevProcessedAtStr != processedAtStr;
    }
    return Column(
      children: [
        if (shouldDisplayDate)
          AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processedAtStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: COLOR_GRAY,
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        InkWell(
          onTap: () => navigateToExplorer(item.hash ?? ''),
          child: AppPadding(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: GenericListTile(
                showMiniIcon: false,
                image: Container(
                  color: COLOR_BLUE,
                  width: 50,
                  height: 50,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/receive_box.svg',
                      width: 25,
                    ),
                  ),
                ),
                title: item.title,
                subtitle: item.subtitle,
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: COLOR_GREEN,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildGenericItem(TxnHistoryItem item, TxnHistoryItem? prevItem) {
    final processedAt = item.processedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(item.processedAt!)
        : DateTime.now();
    final processedAtStr = getFormattedDate(processedAt);
    bool shouldDisplayDate = true;
    if (prevItem != null) {
      final prevProcessedAt = prevItem.processedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(prevItem.processedAt!)
          : DateTime.now();
      final prevProcessedAtStr = getFormattedDate(prevProcessedAt);
      shouldDisplayDate = prevProcessedAtStr != processedAtStr;
    }
    return Column(
      children: [
        if (shouldDisplayDate)
          AppPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processedAtStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: COLOR_GRAY,
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        InkWell(
          onTap: () => navigateToExplorer(item.hash ?? ''),
          child: AppPadding(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: GenericListTile(
                showMiniIcon: false,
                image: const Icon(Icons.more_horiz_outlined),
                title: item.title,
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildHistory(List<TxnHistoryItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final prevItem = index > 0 ? items[index - 1] : null;
        if (item.title == 'Unknown transaction') {
          return buildGenericItem(item, prevItem);
        }
        if (item.subtitle == 'Deposit') {
          return buildDepositItem(item, prevItem);
        } else {
          return buildReceiptItem(item, prevItem);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureUser,
      builder: (_, snapshot) {
        return ScreenScaffold(
          title: Image.asset(
            'assets/images/DePlan_Logo5.png',
            width: 140,
          ),
          child: FutureBuilder(
            future: futureUser,
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final user = snapshot.data;
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder(
                    future: futureBalance,
                    builder: (_, snapshot) {
                      return AccountHeader(balance: snapshot.data, user: user);
                    },
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: FutureBuilder(
                      future: futureHistory,
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        final items = snapshot.data ?? [];
                        return buildHistory(items);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
