@JS()
library deplan;

import 'dart:convert';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('signIn')
external String _signIn();

Future<Map> signIn() async {
  final res = await promiseToFuture(_signIn());
  return jsonDecode(res);
}

@JS('signTransaction')
external String _signTransaction(String transaction);

Future<Map> signTransaction(String transaction) async {
  final res = await promiseToFuture(_signTransaction(transaction));
  return jsonDecode(res);
}

@JS('getKey')
external String _getKey();

Future<String> getKey() {
  return promiseToFuture(_getKey());
}
