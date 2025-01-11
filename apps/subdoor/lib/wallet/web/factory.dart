import 'package:subdoor/wallet/abstract/factory.dart';
import 'package:subdoor/wallet/abstract/wallet.dart';
import 'package:subdoor/wallet/abstract/wallet_provider_registry.dart';
import 'package:subdoor/wallet/web/solana/wallet.dart';
import 'package:subdoor/wallet/web/wallet_provider_registry.dart';

class WebWalletFactory implements WalletFactory {
  @override
  Wallet createSolanaWallet() {
    return SolanaWebWallet();
  }

  @override
  WalletProviderRegistry createWalletProviderRegistry() {
    return WebWalletProviderRegistry();
  }
}
