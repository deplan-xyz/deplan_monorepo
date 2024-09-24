import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:deplan/models/app_link/app_link_data.dart';
import 'package:deplan/models/app_link/app_link_type.dart';

class AppLinkUtils {
  static final _appLink = AppLinks();

  static Stream<AppLinkData?> get stream {
    return _appLink.uriLinkStream.map((uri) => _parseAppLink(uri));
  }

  static Future<AppLinkData?> get initial async {
    final uri = await _appLink.getInitialAppLink();
    if (uri != null) {
      return _parseAppLink(uri);
    }
    return null;
  }

  static AppLinkData? _parseAppLink(Uri uri) {
    if (uri.host == 'open') {
      return AppLinkData(
        AppLinkType.open,
        uri.queryParameters['address'] ?? '',
      );
    } else if (uri.host == 'wc') {
      return AppLinkData(AppLinkType.wc, uri.queryParameters['uri'] ?? '');
    }
    return null;
  }
}
