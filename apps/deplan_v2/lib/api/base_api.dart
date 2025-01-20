import 'package:deplan/api/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const servers = {
  'local': 'http://localhost:9899',
  'dev': 'https://deplan-dev-ae376b80805f.herokuapp.com',
  'prod': 'https://deplan-560eb4c67350.herokuapp.com',
};
final baseUrl = servers[kReleaseMode
    ? 'prod'
    : kProfileMode
        ? 'local'
        : 'dev']!;

class BaseApi {
  late final Dio _dioClient;

  BaseApi() {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        followRedirects: true,
      ),
    );
  }

  @protected
  Dio get client {
    return _dioClient;
  }

  @protected
  Future<Response<T>> getRequest<T>(
    String path, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    final headers = this.headers;
    return client.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  @protected
  Future<Response> postRequest(
    String path, {
    Map<String, dynamic> body = const {},
  }) {
    final headers = this.headers;
    return client.post(
      path,
      data: body,
      options: Options(headers: headers),
    );
  }

  Map<String, String> get headers {
    return _getHeaders();
  }

  Map<String, String> _getHeaders() {
    final token = Auth.deplanAuthToken;
    return {
      'Authorization': 'Bearer $token',
    };
  }
}
