import 'package:deplan_v1/api/base_api.dart';
import 'package:deplan_v1/app_storage.dart';
import 'package:deplan_v1/models/app.dart';
import 'package:deplan_v1/models/app_session.dart';
import 'package:dio/dio.dart';

class _AppsApi extends BaseApi {
  Future<Response> createApp(App app) {
    final data = Map<String, dynamic>.from(app.toMap());

    data['logo'] = MultipartFile.fromBytes(app.logoToSet!, filename: 'logo');

    FormData payload = FormData.fromMap(data);

    return client.post(
      '/apps',
      data: payload,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> getApps(String? type) {
    return client.get('/apps', queryParameters: {'type': type});
  }

  Future<void> recordSession(AppSession session) {
    final sessionJson = session.toJson();
    return appStorage.write('active_session', sessionJson);
  }

  Future<void> clearSession() {
    return appStorage.write('active_session', '');
  }

  Future<String?> getActiveSession() {
    return appStorage.getValue('active_session');
  }

  Future<Response> endSession(AppSession session, {String? txn}) {
    Map data = session.toMap();
    if (txn != null) {
      data['txn'] = txn;
    }
    return client.post('/apps/sessions', data: data);
  }
}

final appsApi = _AppsApi();
