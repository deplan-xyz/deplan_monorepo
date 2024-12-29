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

@JS('signTransaction')
external Object _signTransaction(String tx);

Future<String> signTransaction(String tx) async {
  return promiseToFuture(_signTransaction(tx));
}
