import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:phorevr_v1/api/base_api.dart';

class _StorageApi extends BaseApi {
  Future<Response> store(
    List<Uint8List> files,
    String filename, {
    String? txn,
    Function(int, int)? onSendProgress,
  }) {
    final dataMap = {
      'txn': txn,
    };
    final data = FormData.fromMap(dataMap);
    data.files.addAll(
      files.map(
        (bytes) => MapEntry(
          'files',
          MultipartFile.fromBytes(bytes, filename: filename),
        ),
      ),
    );
    return client.post(
      '/storage',
      data: data,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
      onSendProgress: onSendProgress,
    );
  }

  Future<Response> getFiles() {
    return client.get('/storage');
  }
}

final storageApi = _StorageApi();
