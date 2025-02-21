import 'dart:js' as js;

class TelegramWebAppService {
  static bool get isInTelegram => TelegramWebAppService.getUserId() != null;

  static String? getUserId() {
    try {
      final telegram = js.context['Telegram']?['WebApp'];
      if (telegram != null) {
        final initDataUnsafe = telegram['initDataUnsafe'];
        if (initDataUnsafe != null) {
          return initDataUnsafe['user']['id'].toString();
        }
      }
    } catch (e) {
      print('Not in Telegram environment: $e');
    }
    return null;
  }
}
