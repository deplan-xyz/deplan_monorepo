import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/api/storage_api.dart';

class IpfsUtils {
  static String gatewayUrl = '${storageApi.baseUrl}/phorevr/storage';

  static Future<Uint8List> fetch(String path) async {
    final token = await authApi.token;
    final response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    ).get(
      '$gatewayUrl/$path',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data;
  }
}
