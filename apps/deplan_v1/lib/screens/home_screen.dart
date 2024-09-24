import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:deplan_v1/api/apps_api.dart';
import 'package:deplan_v1/api/user_api.dart';
import 'package:deplan_v1/app_storage.dart';
import 'package:deplan_v1/models/app.dart';
import 'package:deplan_v1/services/app_link_service.dart';
import 'package:deplan_v1/models/app_session.dart';
import 'package:deplan_v1/models/user_balance.dart';
import 'package:deplan_v1/screens/app_iframe_screen.dart';
import 'package:deplan_v1/widgets/form/search_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:deplan_v1/api/auth_api.dart';
import 'package:deplan_v1/api/balance_api.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/screens/account/account_details_screen.dart';
import 'package:deplan_v1/screens/account/account_settings_screen.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

enum AppAction { open, hide }

RegExp urlRegExp = RegExp(
  r'^(?:http|https):\/\/(?:www\.)?(?:[\w-]+\.)*([\w-]{2,}\.\w+)(?:\/[\w-]*)*\/?$|^(?:http|https):\/\/localhost(?::\d{1,5})?$',
  caseSensitive: false,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<User> futureUser;
  late Future<UserBalance?> futureBalance;
  late Future<List<App>?> futureApps;
  late Future<List<App>?> futureDemoApps;
  late Future<List<App>?> futureFeaturedApps;
  late Future<List<App>?> futureNewApps;
  late Future<List<App>?> futureRecentApps;
  List<App>? filteredApps;
  StreamSubscription? _appLinkOpenAddressSub;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
    futureBalance = fetchBalance();
    futureApps = fetchApps();
    futureFeaturedApps = fetchApps(type: 'featured');
    // futureDemoApps = fetchApps(type: 'demo');
    // futureNewApps = fetchApps(type: 'new');
    futureRecentApps = fetchRecentApps();
    initAppLinkOpenAddress();
  }

  @override
  dispose() {
    super.dispose();
    _appLinkOpenAddressSub?.cancel();
  }

  initAppLinkOpenAddress() {
    handleAppLinkAddress(context.read<AppLinkService>().address);
    _appLinkOpenAddressSub =
        context.read<AppLinkService>().addressStream.listen((address) {
      handleAppLinkAddress(address);
    });
  }

  Future<User> fetchUser() =>
      authApi.getMe().then((response) => User.fromJson(response.data['user']));

  Future<UserBalance?> fetchBalance() async {
    final response = await balanceApi.getBalance();
    return UserBalance.fromJson(response.data);
  }

  Future<List<App>?> fetchApps({String? type}) async {
    try {
      final response = await appsApi.getApps(type);
      return (response.data['apps'] as List)
          .map((app) => App.fromJson(app))
          .toList();
    } on DioException catch (e) {
      displayError(e.response?.data['message']);
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<List<App>?> fetchRecentApps() async {
    try {
      final apps = await futureApps;
      final currentRecentJson = await appStorage.getValue('recent_apps');
      final List<dynamic> currentRecent = currentRecentJson != null
          ? const JsonDecoder().convert(currentRecentJson)
          : [];
      final recentApps = currentRecent.map((wallet) {
        return apps?.firstWhereOrNull((app) => app.wallet == wallet);
      });
      return recentApps.whereNotNull().toList();
    } on DioException catch (e) {
      displayError(e.response?.data['message']);
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  handleAppLinkAddress(String address) async {
    if (address.isEmpty) {
      return;
    }
    final apps = await futureApps;
    final app = (apps ?? []).firstWhereOrNull((app) => app.wallet == address);
    if (app != null) {
      handleOpenAppPressed(app.link!);
    } else {
      displayError('App is not found');
    }
  }

  displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future onRefresh() {
    setState(() {
      futureBalance = fetchBalance();
      futureUser = fetchUser();
      futureApps = fetchApps();
      futureFeaturedApps = fetchApps(type: 'featured');
      futureDemoApps = fetchApps(type: 'demo');
      futureNewApps = fetchApps(type: 'new');
    });
    return Future.wait([
      futureBalance,
      futureUser,
      futureApps,
      futureFeaturedApps,
      futureDemoApps,
      futureNewApps,
    ]);
  }

  handleHideAppPressed(App app) async {
    try {
      final user = await futureUser;
      user.hiddenApps?.add(app.id!);
      final userFuture = userApi
          .updateUser(user)
          .then((response) => User.fromJson(response.data));
      setState(() {
        futureApps = userFuture.then((value) => fetchApps());
      });
      await userFuture;
      setState(() {
        futureUser = userFuture;
      });
    } on DioException catch (e) {
      displayError(e.response?.data['message'] ?? 'Error');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  buildWalletRequest(App app) {
    final pricePerHour =
        '\$${app.settings?.pricePerHour?.toStringAsFixed(2)} /hr';
    return PointerInterceptor(
      child: SizedBox(
        width: double.infinity,
        height: 390,
        child: FutureBuilder(
          future: fetchBalance(),
          builder: (context, snapshot) {
            final isBalanceLoading = !snapshot.hasData;
            double balance = 0;
            if (snapshot.hasData) {
              balance = snapshot.data?.usdcBalance ?? 0;
            }
            final canUseApp = balance >= (app.settings?.pricePerHour ?? 0);
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 35,
                      horizontal: 25,
                    ),
                    decoration: const BoxDecoration(
                      color: COLOR_ALMOST_BLACK,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: COLOR_LIGHT_GRAY3,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(app.logo!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: COLOR_LIGHT_GRAY,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          child: Text(
                            pricePerHour,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isBalanceLoading)
                          const Center(
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                color: COLOR_GRAY2,
                                strokeWidth: 1,
                              ),
                            ),
                          ),
                        if (!isBalanceLoading && canUseApp)
                          Text(
                            'Use ${app.name} based on $pricePerHour',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: COLOR_LIGHT_GRAY,
                              height: 1.1,
                            ),
                          ),
                        if (!isBalanceLoading && !canUseApp)
                          Text(
                            'You need at least \$${app.settings?.pricePerHour} in your wallet to start using ${app.name}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: COLOR_LIGHT_GRAY,
                              height: 1.1,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: COLOR_GRAY,
                                  foregroundColor: COLOR_LIGHT_GRAY,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isBalanceLoading || !canUseApp
                                    ? null
                                    : () {
                                        Navigator.of(context).pop(true);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: COLOR_LIGHT_GRAY,
                                  foregroundColor: COLOR_ALMOST_BLACK,
                                  disabledBackgroundColor:
                                      COLOR_GRAY.withOpacity(.7),
                                  disabledForegroundColor: COLOR_LIGHT_GRAY,
                                ),
                                child: const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You only pay for time you actually use the product\nas little as for minutes or even seconds of usage',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: COLOR_GRAY,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: COLOR_GRAY,
                      foregroundColor: COLOR_LIGHT_GRAY2,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  addToRecent(App app) async {
    final currentRecentJson = await appStorage.getValue('recent_apps');
    final List<dynamic> currentRecent = currentRecentJson != null
        ? const JsonDecoder().convert(currentRecentJson)
        : [];
    LinkedHashSet set = LinkedHashSet.from(currentRecent);
    final element = app.wallet;
    if (set.contains(element)) {
      set.remove(element);
    } else if (set.length >= 3) {
      set.remove(set.last);
    }
    set = LinkedHashSet<String>.from([element, ...set]);
    await appStorage.write(
      'recent_apps',
      const JsonEncoder().convert(set.toList()),
    );
  }

  startSession(App app) async {
    final session = AppSession(
      wallet: app.wallet,
      startedAt: DateTime.now().toUtc().toIso8601String(),
    );
    appsApi.recordSession(session);
    await addToRecent(app);
    setState(() {
      futureRecentApps = fetchRecentApps();
    });
  }

  String buildSignInMsg(App app, Map input) {
    return '''
${app.name} would like you to sign in with your DePlan account:
${authApi.walletAddress}

I agree to Sign In to ${input['statement']}

Domain: ${input['domain']}
Requested At: ${input['issuedAt']}
Nonce: ${input['nonce']}''';
  }

  Future<Map> appSignIn(App app, Map input) async {
    final msg = buildSignInMsg(app, input);
    final userSignature = await authApi.signMsg(msg);
    final response = await authApi.getMsgSign(msg);
    final deplanSignature = response.data['signature'];
    return {
      'publicKey': authApi.walletAddress,
      'signedMessage': base58encode(utf8.encode(msg)),
      'signatures': [userSignature.toBase58(), deplanSignature],
    };
  }

  handleOpenAppPressed(String url) async {
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AppIframeScreen(
            url,
            onWalletRequest: (message) async {
              if (message.data?.name == 'SECURE_SVM_CONNECT') {
                message.data?.response = {
                  'publicKey': authApi.walletAddress,
                };
                // FIXME: remove, not secure!!
              } else if (message.data?.name == 'SECURE_SVM_GETKEY') {
                message.data?.response = {
                  'key': await appStorage.getValue('sk'),
                };
              } else if (message.data?.name == 'SECURE_SVM_SIGN_IN') {
                final input = message.data!.request!['input'];
                final appWallet = input['statement'];
                final apps = await futureApps;
                final app = apps?.firstWhereOrNull(
                  (app) {
                    return app.wallet == appWallet;
                  },
                );
                if (app == null) {
                  displayError('App with wallet $appWallet is not found');
                  return message;
                }
                if (mounted) {
                  final isConfirmed = await showModalBottomSheet<bool>(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enableDrag: false,
                    builder: (context) {
                      return buildWalletRequest(app);
                    },
                  );
                  if (isConfirmed != null && isConfirmed) {
                    message.data?.response = await appSignIn(app, input);
                    startSession(app);
                  }
                }
              } else if (message.data?.name == 'SECURE_SVM_SIGN_TX') {
                final txStr =
                    base64Encode(base58decode(message.data?.request?['tx']));
                final result = await authApi.signTxn(txStr);
                final signedTxStr = base58encode(base64Decode(result[0]));
                message.data?.response = {
                  'signature': result[1],
                  'signedTx': signedTxStr,
                };
              }
              return message;
            },
          ),
        ),
      );
    }
    endActiveSession();
  }

  Future endActiveSession() async {
    try {
      final activeSessionJson = await appsApi.getActiveSession();
      if (activeSessionJson == null || activeSessionJson.isEmpty) {
        return;
      }
      final activeSession = AppSession.fromJson(activeSessionJson);
      activeSession.stoppedAt = DateTime.now().toUtc().toIso8601String();
      final response = await appsApi.endSession(activeSession);
      String txn = response.data;
      if (txn.isNotEmpty) {
        final res = await authApi.signTxn(txn);
        txn = res[0];
        await appsApi.endSession(activeSession, txn: txn);
        await appsApi.clearSession();
      }
    } on DioException catch (e) {
      displayError(e.response?.data['message']);
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Widget buildRecentApp(App app) {
    return GestureDetector(
      onTap: () {
        handleOpenAppPressed(app.link!);
      },
      child: Column(
        children: [
          Text(
            app.name ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 5),
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: COLOR_LIGHT_GRAY3,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: COLOR_LIGHT_GRAY3,
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.network(app.logo!),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                color: COLOR_ALMOST_BLACK,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${app.settings?.pricePerHour?.toStringAsFixed(2)} /hr',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: COLOR_WHITE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildApp(App app) {
    return InkWell(
      onTap: () {
        handleOpenAppPressed(app.link ?? '');
      },
      child: AppPadding(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: COLOR_LIGHT_GRAY3,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: COLOR_LIGHT_GRAY3,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.network(app.logo!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                app.link ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.chevron_right,
                          color: COLOR_ALMOST_BLACK,
                          size: 30,
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 4,
                        //     horizontal: 12,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: COLOR_ALMOST_BLACK,
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Text(
                        //     '\$${app.settings?.pricePerHour?.toStringAsFixed(2)} /hr',
                        //     style: const TextStyle(
                        //       fontSize: 14,
                        //       color: COLOR_WHITE,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Text(
                      app.description ?? '',
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<App>> filterApps(String term) async {
    final apps = await futureApps;
    List<App> res = [];
    if (apps != null) {
      final regex = RegExp(term, caseSensitive: false);
      res = apps
          .where(
            (app) =>
                (app.name?.contains(regex) ?? false) ||
                (app.link?.contains(regex) ?? false),
          )
          .toList();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final child = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 30),
              AppPadding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: futureBalance,
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) {
                          return const CupertinoActivityIndicator();
                        }
                        final double balance = snapshot.data?.usdcBalance ?? 0;
                        final double creditsBalance =
                            snapshot.data?.nativeTokenBalance?.uiAmount ?? 0;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              highlightColor: Colors.transparent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AccountDetailsScreen(),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$$balance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$creditsBalance DPLN',
                                    style: const TextStyle(color: COLOR_GRAY),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const AccountSettingsSreen();
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Browse pay-as-you-go web products',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              AppPadding(
                child: Container(
                  decoration: BoxDecoration(
                    color: COLOR_LIGHT_GRAY,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search,
                        size: 25,
                        color: COLOR_GRAY,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: SearchTextField(
                          hintText: 'Search, type website name or paste a link',
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              setState(() {
                                filteredApps = null;
                              });
                            } else {
                              final res = await filterApps(value);
                              setState(() {
                                filteredApps = res;
                              });
                            }
                          },
                          // onSubmitted: (url) {
                          //   final normalizedUrl =
                          //       StringUtils.normalizeUrl(url);
                          //   if (urlRegExp.hasMatch(normalizedUrl)) {
                          //     handleOpenAppPressed(normalizedUrl);
                          //   }
                          // },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 45),
            ],
          ),
        ),
        if (filteredApps == null)
          FutureBuilder(
            future: futureRecentApps,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter();
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final apps = snapshot.data ?? [];
              if (apps.isEmpty) {
                return const SliverToBoxAdapter();
              }
              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    AppPadding(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        ...apps.map((app) => buildApp(app)).toList(),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
        if (filteredApps != null)
          SliverToBoxAdapter(
            child: Column(
              children: [
                Column(
                  children: [
                    ...filteredApps!.map((app) => buildApp(app)).toList(),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        // FutureBuilder(
        //   future: futureDemoApps,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return const SliverToBoxAdapter();
        //     }
        //     if (!snapshot.hasData) {
        //       return const SliverToBoxAdapter();
        //     }
        //     final apps = snapshot.data ?? [];
        //     if (apps.isEmpty) {
        //       return const SliverToBoxAdapter();
        //     }
        //     return SliverList(
        //       delegate: SliverChildListDelegate.fixed(
        //         [
        //           AppPadding(
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Text(
        //                   'Demo products',
        //                   style: Theme.of(context).textTheme.headlineLarge,
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(height: 30),
        //           ...apps.map((app) => buildApp(app)).toList(),
        //           const SizedBox(height: 60),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        if (filteredApps == null)
          FutureBuilder(
            future: futureFeaturedApps,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter();
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter();
              }
              final apps = snapshot.data ?? [];
              if (apps.isEmpty) {
                return const SliverToBoxAdapter();
              }
              return SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    AppPadding(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suggested',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...apps.map((app) => buildApp(app)).toList(),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
        // FutureBuilder(
        //   future: futureNewApps,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return const SliverToBoxAdapter();
        //     }
        //     if (!snapshot.hasData) {
        //       return const SliverToBoxAdapter();
        //     }
        //     final apps = snapshot.data ?? [];
        //     if (apps.isEmpty) {
        //       return const SliverToBoxAdapter();
        //     }
        //     return SliverList(
        //       delegate: SliverChildListDelegate.fixed(
        //         [
        //           AppPadding(
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Text(
        //                   'New',
        //                   style: Theme.of(context).textTheme.headlineLarge,
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(height: 30),
        //           ...apps.map((app) => buildApp(app)).toList(),
        //           const SizedBox(height: 60),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ],
    );
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      body: SafeArea(
        child: Platform.isAndroid
            ? RefreshIndicator(
                onRefresh: onRefresh,
                child: child,
              )
            : child,
      ),
    );
  }
}
