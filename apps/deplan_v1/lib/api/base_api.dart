import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:deplan_v1/api/auth_api.dart';

class BaseApi {
  // final baseUrl = 'http://localhost:9899';
  final baseUrl = 'https://deplan-560eb4c67350.herokuapp.com';
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
