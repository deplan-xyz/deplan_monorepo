import 'package:deplan/api/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const baseUrl = 'https://deplan-560eb4c67350.herokuapp.com';

class BaseApi {
  // final baseUrl = 'http://localhost:9898';
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
  postRequest(String path, {Map<String, dynamic> body = const {}}) async {
    final headers = this.headers;
    try {
      return await client.post(
        path,
        data: body,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      return e.response;
    }
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
