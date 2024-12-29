import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:subdoor/api/auth_api.dart';

const servers = {
  'local': {
    'http': 'http://localhost:9899',
    'ws': 'ws://localhost:9899',
  },
  'prod': {
    'http': 'https://deplan-560eb4c67350.herokuapp.com',
    'ws': 'https://deplan-560eb4c67350.herokuapp.com',
  },
};
final server = servers[kReleaseMode ? 'prod' : 'local']!;

class BaseApi {
  late final String baseUrl;
  late final Dio _dioClient;

  String? inMemoryToken;

  BaseApi() {
    baseUrl = '${server['http']!}/bidonsub';
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
    final token = authApi.inMemoryToken ?? await authApi.token;
    if (token != null) {
      options.headers.addAll({'Authorization': 'Bearer $token'});
    }
    handler.next(options);
  },
);
