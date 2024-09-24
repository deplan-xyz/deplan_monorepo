import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool isWebIOS() {
    return kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool isWebAndroid() {
    return kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
}
