import 'dart:js' as js;

class TelegramWallet {
  static Future<double?> getUSDTBalance() async {
    if (js.context.hasProperty('Telegram')) {
      try {
        // Get tonkeeper API instance
        final tonkeeper = js.context['Telegram']['WebApp']['tonkeeper'];

        // Request balance for USDT
        final balance = await tonkeeper.callMethod('getBalance', ['usdt']);

        // Convert balance to double
        return balance != null ? double.tryParse(balance.toString()) : null;
      } catch (e) {
        print('Error getting USDT balance: $e');
        return null;
      }
    }
    return null;
  }

  static Future<bool> checkWalletExists() async {
    if (js.context.hasProperty('Telegram')) {
      try {
        // Check if wallet exists using Telegram Web App API
        final result = await js.context['Telegram']['WebApp']
            .callMethod('validateWalletAddress');
        return result != null;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static void startWalletCreation() {
    if (js.context.hasProperty('Telegram')) {
      js.context['Telegram']['WebApp'].callMethod('openWallet');
    }
  }

  static void listenToWalletEvents(
    Function() onSuccess,
    Function(String error) onError,
  ) {
    if (js.context.hasProperty('Telegram')) {
      // Listen for successful wallet creation
      js.context['Telegram']['WebApp'].callMethod('onEvent', [
        'walletCreated',
        (event) {
          onSuccess();
        }
      ]);

      // Listen for wallet creation errors
      js.context['Telegram']['WebApp'].callMethod('onEvent', [
        'walletCreateError',
        (error) {
          onError(error.toString());
        }
      ]);
    }
  }

  static void removeWalletListeners() {
    if (js.context.hasProperty('Telegram')) {
      js.context['Telegram']['WebApp']
          .callMethod('offEvent', ['walletCreated']);
      js.context['Telegram']['WebApp']
          .callMethod('offEvent', ['walletCreateError']);
    }
  }
}
