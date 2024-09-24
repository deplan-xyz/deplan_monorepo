class StringUtils {
  static String appendProtocolToURL(
    String url, {
    String defaultProtocol = 'https://',
  }) {
    RegExp protocolRegExp = RegExp(r'^(http:\/\/|https:\/\/)');

    if (!protocolRegExp.hasMatch(url)) {
      return defaultProtocol + url;
    }

    return url;
  }

  static String normalizeUrl(String url) {
    final trimmedUrl = url.trim();
    final urlWithProtocol = StringUtils.appendProtocolToURL(trimmedUrl);
    return Uri.parse(urlWithProtocol).normalizePath().toString();
  }
}
