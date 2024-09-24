import 'package:deplan/api/auth.dart';
import 'package:deplan/app.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Auth.initDeplanAuthToken();

  // run firebase emulators:start and then uncomment this code
  // DO NOT PUSH IT TO PROD UNCOMMENTED!!!!
  // if (kDebugMode && kIsWeb) {
  //   try {
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  runApp(const App());
}
