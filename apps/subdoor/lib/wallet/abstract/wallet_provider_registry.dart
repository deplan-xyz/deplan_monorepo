import 'package:subdoor/wallet/types/wallet_provider.dart';

abstract class WalletProviderRegistry {
  late List<WalletProvider> solanaProviders;

  WalletProviderRegistry() {
    solanaProviders = getSolanaWalletProviders();
  }

  List<WalletProvider> getSolanaWalletProviders();
}
