import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phorevr/api/auth_api.dart';

class BaseApi {
  // final baseUrl = 'http://localhost:9899';
  final baseUrl = 'https://phorevr-09ba19e6f8ae.herokuapp.com';
  late final Dio _dioClient;
  BaseApi() {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        followRedirects: true,
      ),
    );
    _dioClient.interceptors.add(tokenInterceptor);
  }

  @protected
  Dio get client {
    return _dioClient;
  }
}

final tokenInterceptor = InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await authApi.token;
    if (token != null) {
      options.headers.addAll({'Authorization': 'Bearer $token'});
    }
    handler.next(options);
  },
);
