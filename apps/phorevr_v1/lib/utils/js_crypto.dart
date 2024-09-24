@JS()
library crypto;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('encrypt')
external Object _encrypt(String data, String key, String iv);

Future<String> encrypt(String data, String key, String iv) {
  return promiseToFuture(_encrypt(data, key, iv));
}

@JS('decrypt')
external Object _decrypt(String data, String key, String iv);

Future<String> decrypt(String data, String key, String iv) {
  return promiseToFuture(_decrypt(data, key, iv));
}
