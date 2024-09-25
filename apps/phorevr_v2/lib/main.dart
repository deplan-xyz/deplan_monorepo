import 'package:flutter/material.dart';
import 'package:phorevr/utils/web_plugins_shim.dart'
    if (dart.library.js_interop) 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:phorevr/app.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}
