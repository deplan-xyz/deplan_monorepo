import 'package:subdoor/wallet/abstract/wallet_provider_registry.dart';
import 'package:subdoor/wallet/types/wallet_provider.dart';
import 'package:subdoor/wallet/web/solana/js_wallet_api/js_wallet_api.dart'
    as js_wallet_api;

class WebWalletProviderRegistry extends WalletProviderRegistry {
  @override
  List<WalletProvider> getSolanaWalletProviders() {
    return js_wallet_api
        .getWallets()
        .map(
          (wallet) => WalletProvider(
            name: wallet['name'],
            icon: wallet['icon'],
          ),
        )
        .toList();
  }
}
