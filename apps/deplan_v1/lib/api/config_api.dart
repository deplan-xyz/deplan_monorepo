import 'package:deplan/api/base_api.dart';
import 'package:dio/dio.dart';

class _ConfigApi extends BaseApi {
  Future<Response> getConfig() {
    return client.get('/config');
  }
}

final configApi = _ConfigApi();
