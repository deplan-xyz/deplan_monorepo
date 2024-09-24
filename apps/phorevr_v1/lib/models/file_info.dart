import 'package:flutter/services.dart';

class FileInfo {
  String? cid;
  String? ext;
  String? txnHash;
  Uint8List? data;

  String get smallPath {
    return '$cid/small.$ext';
  }

  String get fullPath {
    return '$cid/full.$ext';
  }

  FileInfo.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    ext = json['ext'];
    txnHash = json['txnHash'];
  }
}
