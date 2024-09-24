import 'dart:async';

import 'package:deplan_v1/models/app_link/app_link_data.dart';
import 'package:deplan_v1/models/app_link/app_link_type.dart';
import 'package:deplan_v1/utils/app_link.dart';

class AppLinkService {
  final StreamController<String> _addressCtrl =
      StreamController<String>.broadcast();
  final StreamController<String> _wcUriCtrl =
      StreamController<String>.broadcast();
  String _address = '';
  String _wcUri = '';

  Future<AppLinkService> init() async {
    final data = await AppLinkUtils.initial;
    if (data != null) {
      _handleData(data);
    }
    AppLinkUtils.stream.listen((data) {
      if (data != null) {
        _handleData(data);
      }
    });
    return this;
  }

  Stream<String> get addressStream {
    return _addressCtrl.stream;
  }

  Stream<String> get wcUriStream {
    return _wcUriCtrl.stream;
  }

  String get address {
    final a = _address;
    _address = '';
    return a;
  }

  String get wcUri {
    final u = _wcUri;
    _wcUri = '';
    return u;
  }

  _handleData(AppLinkData data) {
    if (data.type == AppLinkType.open) {
      _address = data.data;
      _addressCtrl.add(_address);
    } else if (data.type == AppLinkType.wc) {
      _wcUri = data.data;
      _wcUriCtrl.add(_wcUri);
    }
  }

  addData(AppLinkData data) {
    _handleData(data);
  }
}
