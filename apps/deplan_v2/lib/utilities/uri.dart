String? getOrgIdFromUri(Uri? uri) {
  if (uri != null && uri.queryParameters.containsKey('orgId')) {
    String orgId = uri.queryParameters['orgId'] ?? '';
    return orgId;
  }

  return null;
}
