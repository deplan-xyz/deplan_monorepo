@JS()
library wallet_api;

import 'dart:convert';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('getWallets')
external String _getWallets();

List<dynamic> getWallets() {
  return jsonDecode(_getWallets());
}

@JS('signIn')
external Object _signIn(String walletName);

Future<dynamic> signIn(String walletName) async {
  return jsonDecode(await promiseToFuture(_signIn(walletName)));
}
