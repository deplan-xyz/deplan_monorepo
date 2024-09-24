import 'package:deplan/api/auth_api.dart';
import 'package:deplan/services/app_link_service.dart';
import 'package:deplan/services/navigator_service.dart';
import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnect extends StatefulWidget {
  const WalletConnect({super.key});

  @override
  State<WalletConnect> createState() => _WalletConnectState();
}

class _WalletConnectState extends State<WalletConnect> {
  late Web3Wallet web3Wallet;

  NavigatorState get navigator => NavigatorService.navigatorKey.currentState!;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    web3Wallet = await Web3Wallet.createInstance(
      projectId: '0944ad32c4a4e58ab4ec9509a1735f62',
      metadata: const PairingMetadata(
        name: 'DePlan',
        description: 'The new browser for the new internet.',
        url: 'https://deplan.xyz',
        icons: [
          'https://assets.coingecko.com/coins/images/36429/small/deplan_token.png',
        ],
        redirect: Redirect(
          native: 'deplan://',
          universal: 'https://deplan.xyz',
        ),
      ),
    );
    web3Wallet.core.pairing.onPairingInvalid.subscribe(
      (args) {
        print('onPairingInvalid');
      },
    );
    web3Wallet.core.pairing.onPairingCreate.subscribe(
      (args) {
        print('onPairingCreate');
      },
    );
    web3Wallet.onSessionProposal.subscribe(
      (args) async {
        handleSessionProposal(args);
      },
    );
    web3Wallet.onSessionConnect.subscribe(
      (args) {
        print('onSessionConnect');
      },
    );
    web3Wallet.onSessionProposalError.subscribe(
      (args) {
        print('onSessionProposalError');
      },
    );
    web3Wallet.onAuthRequest.subscribe(
      (args) {
        print('onAuthRequest');
      },
    );
    web3Wallet.core.relayClient.onRelayClientError.subscribe(
      (args) {
        print('onRelayClientError');
      },
    );
    web3Wallet.core.relayClient.onRelayClientMessage.subscribe(
      (args) {
        print('onRelayClientMessage');
      },
    );
    await web3Wallet.init();
    initAppLink();
  }

  initAppLink() {
    handleAppLink(context.read<AppLinkService>().wcUri);
    context.read<AppLinkService>().wcUriStream.listen((wcUri) {
      handleAppLink(wcUri);
    });
  }

  handleAppLink(String wcUri) async {
    if (wcUri.isEmpty) {
      return;
    }
    await web3Wallet.pair(
      uri: Uri.parse(wcUri),
    );
  }

  buildNamespaces(String address) {
    return {
      'solana': Namespace(
        accounts: [
          'solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp:$address',
        ],
        methods: [
          'solana_signMessage',
          'solana_signTransaction',
        ],
        events: [],
      ),
    };
  }

  displayWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  rejectAndDisconnect(SessionProposalEvent? event) async {
    await web3Wallet.rejectSession(
      id: event!.id,
      reason: Errors.getSdkError(Errors.USER_REJECTED),
    );
    await web3Wallet.core.pairing.disconnect(
      topic: event.params.pairingTopic,
    );
  }

  buildConnectionRequest(PairingMetadata? metadata) {
    return SizedBox(
      width: double.infinity,
      height: 390,
      child: Stack(
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
                  if (metadata?.icons.isNotEmpty ?? false)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: COLOR_LIGHT_GRAY3,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.network(metadata!.icons.last),
                      ),
                    ),
                  const SizedBox(height: 45),
                  Text(
                    '${Uri.parse(metadata?.url ?? '').host}\nwants to know your DePlan wallet address',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: COLOR_WHITE,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            navigator.pop();
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
                          onPressed: () {
                            navigator.pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: COLOR_LIGHT_GRAY,
                            foregroundColor: COLOR_ALMOST_BLACK,
                            disabledBackgroundColor: COLOR_GRAY.withOpacity(.7),
                            disabledForegroundColor: COLOR_LIGHT_GRAY,
                          ),
                          child: const Text('OK'),
                        ),
                      ),
                    ],
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
                navigator.pop();
              },
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: COLOR_GRAY,
                foregroundColor: COLOR_LIGHT_GRAY2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  handleSessionProposal(SessionProposalEvent? event) async {
    print('onSessionProposal');
    final address = authApi.walletAddress;
    if (address == null) {
      displayWarning('Connection is not possible. Please sign in.');
      await rejectAndDisconnect(event);
      return;
    }
    final isConfirmed = await showModalBottomSheet<bool>(
      context: NavigatorService.navigatorKey.currentContext!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      enableDrag: false,
      builder: (context) {
        return buildConnectionRequest(event?.params.proposer.metadata);
      },
    );
    if (isConfirmed == null || !isConfirmed) {
      await rejectAndDisconnect(event);
    } else {
      final ns = buildNamespaces(address);
      await web3Wallet.approveSession(
        id: event!.id,
        namespaces: ns,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
