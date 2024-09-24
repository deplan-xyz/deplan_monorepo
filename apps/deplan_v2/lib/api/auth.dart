import 'dart:developer';

import 'package:deplan/api/base_api.dart';
import 'package:deplan/app_storage.dart';
import 'package:deplan/constants/common.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Auth {
  static String deplanAuthToken = '';
  static Dio get client {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        followRedirects: true,
      ),
    );
  }

  static Future<void> _getAndSetDeplanAuthToken() async {
    final deplantokenfromStorage =
        await appStorage.getValue(deplanAuthTokenKey);
    if (deplantokenfromStorage == null) {
      final deplantoken = await Auth.getDeplanAuthToken();
      Auth.deplanAuthToken = deplantoken;
      await appStorage.write(deplanAuthTokenKey, deplantoken);
      print('Deplan token set in storage');
    } else {
      print('Deplan token found in storage');
      Auth.deplanAuthToken = deplantokenfromStorage;
    }
  }

  static Future<void> signInWithApple(OAuthCredential credentials) async {
    final appleProvider = OAuthProvider('apple.com')
      ..addScope('name')
      ..addScope('email');

    if (kIsWeb) {
      try {
        await FirebaseAuth.instance.signInWithCredential(credentials);
      } on FirebaseAuthException catch (err) {
        print('Auth error: ${err.code}');
        rethrow;
      }

      await _getAndSetDeplanAuthToken();
    } else {
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
      await _getAndSetDeplanAuthToken();
    }
  }

  static Future<void> signUpWithCredentials(
      String email, String password,) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final deplanToken = await getDeplanAuthToken();
      await appStorage.write(deplanAuthTokenKey, deplanToken);
      Auth.deplanAuthToken = deplanToken;
    } on FirebaseAuthException catch (e) {
      print('Error signing up: ${e.code}');
      rethrow;
    } catch (e) {
      print(e);
    }
  }

  static Future<UserCredential?> signInWithCredentials(
      String email, String password,) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final deplanToken = await getDeplanAuthToken();
      await appStorage.write(deplanAuthTokenKey, deplanToken);
      Auth.deplanAuthToken = deplanToken;
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        print('User not found or wrong credentials');
      } else {
        log('Error signing in: ${e.code}');
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await appStorage.deleteValue(deplanAuthTokenKey);
    } catch (e) {
      print('Error deleting deplan auth token: $e');
    }
    Auth.deplanAuthToken = '';
  }

  static Future<String> getDeplanAuthToken() async {
    final firebaseUserId = FirebaseAuth.instance.currentUser?.uid;
    final response = await client.post('/auth/signin/firebase',
        data: {'firebaseUserId': firebaseUserId},);
    return response.data['token'];
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static bool get isUserAuthenticated =>
      FirebaseAuth.instance.currentUser != null;
  static Future<String?>? get authToken =>
      FirebaseAuth.instance.currentUser?.getIdToken();

  static onUserLoggedIn(Function(User) callback) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        callback(user);
      }
    });
  }

  static onUserLoggedOut(Function() callback) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        callback();
      }
    });
  }

  static initDeplanAuthToken() async {
    final deplantokenfromStorage =
        await appStorage.getValue(deplanAuthTokenKey);
    if (deplantokenfromStorage != null) {
      Auth.deplanAuthToken = deplantokenfromStorage;
    }
  }
}
