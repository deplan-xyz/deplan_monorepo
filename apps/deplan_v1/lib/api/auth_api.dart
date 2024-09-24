import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:deplan_v1/api/base_api.dart';
import 'package:deplan_v1/app_storage.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/utils/crypto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

class _AuthApi extends BaseApi {
  Ed25519HDKeyPair? _keyPair;

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

  String? get walletAddress {
    return _keyPair?.address;
  }

  Future<Response> getMe() async {
    return client.get('/auth/me');
  }

  Future<Response> signup(
    User user,
    Ed25519HDKeyPair keyPair,
  ) async {
    final Map<String, dynamic> userMap = {
      'username': user.username,
      'wallet': user.wallet,
      'password': user.password,
    };

    if (user.avatarToSet != null) {
      userMap['avatar'] =
          MultipartFile.fromBytes(user.avatarToSet!, filename: 'avatar');
    }

    FormData payload = FormData.fromMap(userMap);

    final response = await client.post(
      '/auth/signup',
      data: payload,
      options: Options(contentType: 'multipart/form-data'),
    );
    _keyPair = keyPair;
    await appStorage.write('sk', await CryptoUtils.getSecretKey(keyPair));
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  Future<Response> restore(Ed25519HDKeyPair keyPair, String password) async {
    final response = await client.post(
      '/auth/restore',
      data: {
        'wallet': keyPair.address,
        'password': password,
      },
    );
    _keyPair = keyPair;
    await appStorage.write('sk', await CryptoUtils.getSecretKey(keyPair));
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  logout() async {
    _keyPair?.destroy();
    _keyPair = null;
    await appStorage.deleteValue('sk');
    await appStorage.deleteValue('jwt_token');
    await appStorage.deleteValue('recent_apps');
  }

  deleteAccount() async {
    await client.delete('/auth/me');
    await logout();
  }

  initWallet() async {
    final sk = await appStorage.getValue('sk');
    _keyPair = await CryptoUtils.keypairFromSk(sk ?? '');
  }

  Future<Response> getMsgSign(String msg) {
    return client.post('/auth/msg/sign', data: {'msg': msg});
  }

  Future<List<String>> signTxn(String txn) async {
    final tx = SignedTx.decode(txn);
    final signature = await _keyPair!.sign(tx.compiledMessage.toByteArray());
    final signedTx = SignedTx(
      compiledMessage: tx.compiledMessage,
      signatures: List.from(tx.signatures)
        ..removeWhere((signature) => signature.publicKey == _keyPair?.publicKey)
        ..add(signature),
    );
    final res = [signedTx.encode(), signature.toBase58()];
    return res;
  }

  Future<Signature> signMsg(String message) async {
    return _keyPair!.sign(utf8.encode(message));
  }
}

final authApi = _AuthApi();
