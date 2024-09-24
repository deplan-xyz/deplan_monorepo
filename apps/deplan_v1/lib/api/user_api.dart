import 'package:deplan_v1/api/base_api.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:dio/dio.dart';

class _UserApi extends BaseApi {
  Future<Response> updateUser(User user) {
    return client.put('/users/${user.id}', data: user.toMap());
  }
}

final userApi = _UserApi();
