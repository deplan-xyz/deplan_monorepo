import 'package:deplan/screens/signin.dart';
import 'package:deplan/screens/subsciptions_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

_checkAuthAndRedirect() {
  final user = FirebaseAuth.instance.currentUser;
  final bool isUserAuthenticated = user != null;

  return MaterialPageRoute(
    builder: (context) =>
        isUserAuthenticated ? const SubsciptionsHome() : const Signin(),
  );
}

_handleOrgIdQueryParam(RouteSettings settings) {
  final Uri uri = Uri.parse(settings.name!);
  String? orgId = uri.queryParameters['orgId'];
  String? redirectUrl = uri.queryParameters['redirectUrl'];
  String? data = uri.queryParameters['data'];

  if (orgId != null && redirectUrl != null && data != null) {
    // 1. check deplan token in flutter_secure_storage
    // 2. if not found, redirect to signin
    // 3. if found, continue to confirm subscription
  }

  return null;
}

handleQueryParamsParameter(RouteSettings settings) {
  if (kIsWeb) {
    // Handle web-based routing
    final confirmSubscriptioRoute = _handleOrgIdQueryParam(settings);

    if (confirmSubscriptioRoute != null) {
      return confirmSubscriptioRoute;
    }

    return _checkAuthAndRedirect();
  }
  // If it's not web, fall back to default routing.
  return _checkAuthAndRedirect();
}
