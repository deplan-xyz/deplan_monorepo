import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iw_app/api/auth_api.dart';
import 'package:iw_app/api/orgs_api.dart';
import 'package:iw_app/api/users_api.dart';
import 'package:iw_app/app_storage.dart';
import 'package:iw_app/l10n/generated/app_localizations.dart';
import 'package:iw_app/models/account_model.dart';
import 'package:iw_app/models/config_model.dart';
import 'package:iw_app/models/organization_member_model.dart';
import 'package:iw_app/models/organization_model.dart';
import 'package:iw_app/screens/account/account_details_screen.dart';
import 'package:iw_app/screens/account_settings/settings_screen.dart';
import 'package:iw_app/screens/assets/asset_screen.dart';
import 'package:iw_app/screens/organization/create_org_screen.dart';
import 'package:iw_app/screens/organization/org_details/org_details_screen.dart';
import 'package:iw_app/theme/app_theme.dart';
import 'package:iw_app/utils/url.dart';
import 'package:iw_app/widgets/components/accounts_list.dart';
import 'package:iw_app/widgets/components/bottom_sheet_custom.dart';
import 'package:iw_app/widgets/components/bullet_span.dart';
import 'package:iw_app/widgets/components/org_member_card.dart';
import 'package:iw_app/widgets/components/org_member_card_lite.dart';
import 'package:iw_app/widgets/list/assets_list_tile.dart';
import 'package:iw_app/widgets/media/network_image_auth.dart';
import 'package:iw_app/widgets/state/config.dart';
import 'package:iw_app/widgets/utils/app_padding.dart';
import 'package:rxdart/rxdart.dart';

const LAMPORTS_IN_SOL = 1000000000;

class HomeScreen extends StatefulWidget {
  final bool? isOnboarding;
  const HomeScreen({Key? key, this.isOnboarding}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<int> assets = [];
  final bonusExpirationSubject = BehaviorSubject<Duration?>();
  Timer? timer;
  late Future<Account> futureAccount;
  late Future<List<OrganizationMemberWithOtherMembers>> futureAccountMembers;
  late Future<List<OrganizationMemberWithOtherMembers>> futureUserMembers;
  late Future<Map<String, double?>> futureBalance;

  @override
  void initState() {
    super.initState();
    futureAccount = fetchAccount();
    futureAccountMembers = fetchAccountMembers();
    futureUserMembers = fetchUserMembers();
    futureBalance = fetchBalance();
    startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final redirectTo = await appStorage.getValue('redirect_to');
      if (redirectTo != null && mounted) {
        Navigator.of(context).pushNamed(redirectTo);
        appStorage.deleteValue('redirect_to');
      }
    });
  }

  @override
  void dispose() {
    bonusExpirationSubject.close();
    timer?.cancel();
    super.dispose();
  }

  Config get config => ConfigState.of(context).config;

  startTimer() async {
    final account = await futureAccount;
    final balance = await futureBalance;
    if (account.user == null || balance['bonusBalance'] == 0) return;
    timer = Timer.periodic(const Duration(seconds: 1), updateTimeLeft);
  }

  updateTimeLeft(Timer timer) async {
    final account = await futureAccount;
    final user = account.user;
    final createdAt = DateTime.parse(user!.createdAt!);
    final bonusExpiration =
        createdAt.add(Duration(minutes: config.bonusWalletExpiration!));
    if (DateTime.now().isAfter(bonusExpiration)) {
      timer.cancel();
      return;
    }
    final timeLeft = bonusExpiration.difference(DateTime.now());
    bonusExpirationSubject.add(timeLeft);
  }

  Future<Account> fetchAccount() =>
      authApi.getMe().then((response) => Account.fromJson(response.data));

  Future<List<OrganizationMemberWithOtherMembers>> fetchMembers(
    Function(String) getMemberships,
    String id,
  ) async {
    Response response = await getMemberships(id);
    final members = (response.data['list'] as List).map((member) {
      final m = OrganizationMember.fromJson(member);
      final memberWithOther = OrganizationMemberWithOtherMembers(
        member: m,
      );
      final futureOtherMembers = fetchOtherMembers(m.org.id);
      final futureEquity = fetchMemberEquity(m.org.id, m.id!, memberWithOther);
      memberWithOther.futureOtherMembers = futureOtherMembers;
      memberWithOther.futureEquity = futureEquity;
      return memberWithOther;
    }).toList();
    return members;
  }

  Future<List<OrganizationMemberWithOtherMembers>> fetchAccountMembers() async {
    final userId = await authApi.userId;
    final orgId = await authApi.orgId;
    Function(String) fn = usersApi.getMemberships;
    String? id = userId;
    if (orgId != null) {
      fn = orgsApi.getMemberships;
      id = orgId;
    }
    return fetchMembers(fn, id!);
  }

  Future<List<OrganizationMemberWithOtherMembers>> fetchUserMembers() async {
    final userId = await authApi.userId;
    return fetchMembers(usersApi.getMemberships, userId!);
  }

  Future<Map<String, dynamic>> fetchOtherMembers(String orgId) async {
    final response = await orgsApi.getOrgMembers(orgId, limit: 3);
    return {
      'members': (response.data['list'] as List)
          .map((member) => OrganizationMember.fromJson(member))
          .toList(),
      'total': response.data['total'],
    };
  }

  Future<String> fetchMemberEquity(
    String orgId,
    String memberId,
    OrganizationMemberWithOtherMembers member,
  ) async {
    final response = await orgsApi.getMemberEquity(orgId, memberId);
    final tokenAmount = TokenAmount.fromJson(response.data);
    final equity = tokenAmount.uiAmountString;
    member.equity = equity;
    return equity!;
  }

  Future<Map<String, double?>> fetchBalance() async {
    final response = await usersApi.getBalance();
    final balance =
        TokenAmount.fromJson(response.data['balance']['balance']).uiAmount;
    final bonusBalanceJson = response.data['balance']['bonusBalance'];
    final usdcBalance = response.data['balance']['usdcBalance'];
    final double? bonusBalance = bonusBalanceJson != null
        ? TokenAmount.fromJson(
            bonusBalanceJson,
          ).uiAmount
        : 0;

    return {
      'balance': balance,
      'bonusBalance': bonusBalance,
      'usdcBalance': usdcBalance,
    };
  }

  navigateToCreateOrg() async {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CreateOrgScreen(),
        ),
      );
    }
  }

  buildOrganizationCard(
    BuildContext context,
    OrganizationMember member,
    Future<Map<String, dynamic>> futureOtherMembers,
    Future<String>? futureEquity,
  ) {
    Config config = ConfigState.of(context).config;
    final card = config.mode == Mode.Pro
        ? OrgMemberCard(
            member: member,
            futureOtherMembers: futureOtherMembers,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrgDetailsScreen(
                    orgId: member.org.id,
                    member: member,
                  ),
                ),
              );
            },
          )
        : OrgMemberCardLite(
            member: member,
            futureEquity: futureEquity,
            futureOtherMembers: futureOtherMembers,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrgDetailsScreen(
                    orgId: member.org.id,
                    member: member,
                    futureEquity: futureEquity,
                  ),
                ),
              );
            },
          );
    return card;
  }

  buildAssetExample() {
    Config config = ConfigState.of(context).config;
    return AssetsListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: COLOR_LIGHT_GRAY2,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      name: AppLocalizations.of(context)!.homeScreen_assetsExampleTitle,
      account: '@orgs_account',
      tokensAmount: config.mode == Mode.Pro ? '-' : null,
      equity: '-',
    );
  }

  buildAsset(OrganizationMemberWithOtherMembers omm) {
    return FutureBuilder(
      future: omm.futureEquity,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssetScreen(memberWithEquity: omm),
              ),
            );
          },
          child: AssetsListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: FittedBox(
                fit: BoxFit.cover,
                child: NetworkImageAuth(
                  imageUrl: '${orgsApi.baseUrl}${omm.member!.org.logo}',
                ),
              ),
            ),
            name: omm.member!.org.name,
            account: '@${omm.member!.org.username}',
            equity: '${snapshot.data}%',
          ),
        );
      },
    );
  }

  buildAssets(List<OrganizationMemberWithOtherMembers> members) {
    List<OrganizationMemberWithOtherMembers> assets = members;
    return Column(
      children: [
        ...assets.map((m) => buildAsset(m)).toList(),
      ],
    );
  }

  Future onRefresh() {
    setState(() {
      futureAccountMembers = fetchAccountMembers();
      futureBalance = fetchBalance();
      futureAccount = fetchAccount();
    });
    return Future.wait([futureAccountMembers, futureBalance, futureAccount]);
  }

  onAccountsPressed(Account? account) async {
    dynamic res = await showBottomSheetCustom(
      context,
      title: 'Accounts',
      child: FutureBuilder(
        future: futureUserMembers,
        builder: (builder, membersSnapshot) {
          if (!membersSnapshot.hasData) {
            return Container();
          }
          return AccountsListWidget(
            currentAccount: account,
            orgs: membersSnapshot.data,
          );
        },
      ),
    );

    try {
      Response? response;
      if (res == account?.user) {
        response = await usersApi.loginWithToken();
      } else if (res != null) {
        Organization org =
            (res as OrganizationMemberWithOtherMembers).member!.org;
        response = await orgsApi.loginAsOrg(org.id!);
      }
      if (response != null) {
        await appStorage.write('jwt_token', response.data['token']);
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  showBonusFlow(double? bonusBalance) {
    const bulletTextStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: COLOR_ALMOST_BLACK,
    );

    showBottomSheetCustom(
      context,
      right: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Skip',
          style: TextStyle(
            color: COLOR_BLUE,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset(
                'assets/images/fireworks_colored.svg',
                width: 70,
                height: 70,
              ),
              SvgPicture.asset(
                'assets/images/gift_colored.svg',
                width: 130,
                height: 130,
              ),
              SvgPicture.asset(
                'assets/images/fireworks_colored.svg',
                width: 70,
                height: 70,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bonusBalance == 5
                ? 'You got \$${bonusBalance?.toStringAsFixed(2)} DPLN on your bonus wallet!'
                : bonusBalance == 2
                    ? '\$$bonusBalance DPLN left on your\nbonus wallet! '
                    : '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              color: COLOR_ALMOST_BLACK,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 25),
          Visibility(
            visible: bonusBalance == 5,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'You are 2 steps away from understanding how DePlan works',
                style: TextStyle(
                  fontSize: 22,
                  color: COLOR_ALMOST_BLACK,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                  visible: bonusBalance == 5,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Buy Equity in a project',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: COLOR_ALMOST_BLACK,
                        ),
                      ),
                      Text(
                        '2. Make a purchase and get share or revenue',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: COLOR_ALMOST_BLACK,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: bonusBalance == 2,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BulletText(
                        text: 'Go to the website',
                        style: bulletTextStyle,
                      ),
                      BulletText(
                        text:
                            'Buy a sample of the book to get a share of revenue',
                        style: bulletTextStyle,
                      ),
                      BulletText(
                        text: 'Check your wallet',
                        style: bulletTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    bonusBalance == 5
                        ? 'It will take 30 seconds'
                        : bonusBalance == 2
                            ? 'Finish it'
                            : '',
                    style: const TextStyle(
                      color: COLOR_LIGHT_GREEN,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: Text(
                    bonusBalance == 5
                        ? 'Check it out'
                        : bonusBalance == 2
                            ? 'Get back to the site'
                            : '',
                  ),
                  onPressed: () {
                    launchURL(
                      Uri.parse(
                        'https://readwriteown-hack.xyz',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Config config = ConfigState.of(context).config;
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: FutureBuilder(
          future: futureAccount,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            final account = snapshot.data;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => onAccountsPressed(account),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: COLOR_GRAY2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: account?.image != null
                              ? FutureBuilder(
                                  future: usersApi.getAvatar(account!.image!),
                                  builder: (_, snapshot) {
                                    if (!snapshot.hasData) return Container();
                                    return Image.memory(snapshot.data!);
                                  },
                                )
                              : const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    CupertinoIcons.person_fill,
                                    color: COLOR_WHITE,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(account?.username ?? ''),
                      const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: COLOR_ALMOST_BLACK,
        ),
        actions: [
          FutureBuilder(
            future: futureAccount,
            builder: (ctx, snp) {
              if (!snp.hasData) {
                return Container();
              }

              final account = snp.data;
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SettingsSreen(
                          account: account,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: futureAccountMembers,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final members = snapshot.data ?? [];
            final screenWidth = MediaQuery.of(context).size.width;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: onRefresh,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppPadding(
                          child: FutureBuilder(
                            future: futureBalance,
                            builder: (_, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator
                                    .adaptive();
                              }
                              final double balance =
                                  snapshot.data!['balance'] ?? 0;
                              final double usdcBalance =
                                  snapshot.data!['usdcBalance'] ?? 0;
                              final bonusBalance = snapshot
                                  .data!['bonusBalance']
                                  ?.toStringAsFixed(2);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AccountDetailsScreen(),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '\$$usdcBalance',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons
                                                  .keyboard_arrow_down_outlined,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '$balance DPLN',
                                          style: const TextStyle(
                                            color: COLOR_GRAY,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Visibility(
                                    visible:
                                        (snapshot.data!['bonusBalance'] ?? 0) >
                                            0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: bonusBalance == '0'
                                                  ? null
                                                  : () {
                                                      showBonusFlow(
                                                        snapshot.data![
                                                            'bonusBalance'],
                                                      );
                                                    },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '\$$bonusBalance',
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: COLOR_LIGHT_GREEN,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  SvgPicture.asset(
                                                    width: 29,
                                                    height: 29,
                                                    'assets/images/gift_colored.svg',
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    CupertinoIcons
                                                        .info_circle_fill,
                                                    color: COLOR_RED2,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 19),
                                          child: StreamBuilder<Duration?>(
                                            stream:
                                                bonusExpirationSubject.stream,
                                            builder: (_, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container();
                                              }
                                              final timeLeft = snapshot.data!;
                                              int hours = timeLeft.inHours;
                                              int minutes = timeLeft.inMinutes
                                                  .remainder(60);
                                              int seconds = timeLeft.inSeconds
                                                  .remainder(60);
                                              return Text(
                                                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: COLOR_RED2,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 45),
                      AppPadding(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              config.mode == Mode.Lite
                                  ? 'Your Products'
                                  : AppLocalizations.of(context)!
                                      .homeScreen_organizationsTitle,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            if (snapshot.data!.isNotEmpty)
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: navigateToCreateOrg,
                                child: SvgPicture.asset(
                                  'assets/icons/add_circle.svg',
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: members.isNotEmpty
                      ? SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                screenWidth < 600 ? screenWidth : 450,
                            mainAxisExtent: 300,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          itemBuilder: (_, i) {
                            final member = members[i];
                            return buildOrganizationCard(
                              context,
                              member.member!,
                              member.futureOtherMembers!,
                              member.futureEquity,
                            );
                          },
                          itemCount: members.length,
                        )
                      : SliverToBoxAdapter(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: 200,
                            height: 290,
                            child: OrgMemberCard(
                              onTap: navigateToCreateOrg,
                            ),
                          ),
                        ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                  ),
                ),
                if (config.mode == Mode.Pro)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 45),
                        AppPadding(
                          child: Text(
                            AppLocalizations.of(context)!
                                .homeScreen_assetsTitle,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 15),
                        AppPadding(
                          child: snapshot.data!.isEmpty
                              ? buildAssetExample()
                              : buildAssets(snapshot.data!),
                        ),
                      ],
                    ),
                  ),
                if (snapshot.data!.isEmpty)
                  SliverToBoxAdapter(
                    child: AppPadding(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          SvgPicture.asset(
                            'assets/icons/arrow_up_big.svg',
                          ),
                          const SizedBox(height: 15),
                          Text(
                            config.mode == Mode.Pro
                                ? AppLocalizations.of(context)!
                                    .homeScreen_assetsExampleDesc
                                : 'Your Assets will appear here when you create or join Organization or Project',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
}
