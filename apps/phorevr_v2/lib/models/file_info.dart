import 'package:flutter/services.dart';

class FileInfo {
  String? mimetype;
  String? entityId;
  Uint8List? data;

  FileInfo.fromJson(Map<String, dynamic> json) {
    mimetype = json['mimetype'];
    entityId = json['entityId'];
  }
}
