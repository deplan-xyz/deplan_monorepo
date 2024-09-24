import 'dart:typed_data';

import 'package:dio/dio.dart';

class IpfsUtils {
  static String gatewayUrl = 'https://nftstorage.link/ipfs';

  static Future<Uint8List> fetch(String path) async {
    final response = await Dio().get(
      '$gatewayUrl/$path',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data;
  }
}
