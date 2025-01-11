import 'package:subdoor/wallet/abstract/wallet.dart';
import 'package:subdoor/wallet/abstract/wallet_provider_registry.dart';

abstract interface class WalletFactory {
  Wallet createSolanaWallet();

  WalletProviderRegistry createWalletProviderRegistry();
}
