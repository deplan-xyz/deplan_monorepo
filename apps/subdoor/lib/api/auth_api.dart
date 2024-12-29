import 'package:subdoor/api/app_storage.dart';
import 'package:subdoor/api/base_api.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class _AuthApi extends BaseApi {
  Future<String?> get token {
    return appStorage.getValue('jwt_token');
  }

  Future<String?> get userId async {
    final decodedToken = JwtDecoder.decode((await token) ?? '');

    if (decodedToken.isEmpty) {
      return null;
    }

    return decodedToken['sub'];
  }

  Future<Response> getMe() async {
    return client.get('/auth/me');
  }

  Future<Response> signinApple(
    String authorizationCode,
    bool useBundleId,
    String redirectUrl,
  ) async {
    final response = await client.post(
      '/auth/signin/apple',
      data: {
        'authorizationCode': authorizationCode,
        'useBundleId': useBundleId,
        'redirectUrl': redirectUrl,
      },
    );
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  Future<Response> signinBasic(String email, String password) async {
    final response = await client.post(
      '/auth/signin/basic',
      data: {
        'email': email,
        'password': password,
      },
    );
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  Future<Response> signupBasic(
    String email,
    String username,
    String password,
  ) async {
    final response = await client.post(
      '/auth/signup/basic',
      data: {
        'email': email,
        'username': username,
        'password': password,
      },
    );
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  Future<Response> signinSolana(
    String signature,
    String message,
    String address,
  ) async {
    final response = await client.post(
      '/auth/signin/solana',
      data: {
        'signature': signature,
        'message': message,
        'address': address,
      },
    );

    inMemoryToken = response.data['token'];

    return response;
  }

  logout() async {
    await appStorage.deleteValue('jwt_token');
  }

  Future<Response> deleteAccount() async {
    await logout();
    return client.delete('/auth/me');
  }
}

final authApi = _AuthApi();
