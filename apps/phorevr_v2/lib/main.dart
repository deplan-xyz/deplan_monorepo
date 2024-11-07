import 'package:flutter/material.dart';
import 'package:deplan_core/utils/deplan_utils.dart'
    if (dart.library.js_interop) 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:phorevr/app.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}
