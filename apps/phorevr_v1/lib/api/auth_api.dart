import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:phorevr/api/base_api.dart';
import 'package:phorevr/app_storage.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/utils/crypto.dart';
import 'package:phorevr/utils/js_deplan.dart';
import 'package:solana/base58.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

class DePlanSignInData {
  String? wallet;
  String? signInMsg;
  String? signature;

  DePlanSignInData({
    this.signInMsg,
    this.signature,
    this.wallet,
  });
}

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

  Future<Response> signupDeplan(
    User user,
    DePlanSignInData dePlanSignInData,
  ) async {
    final Map<String, dynamic> userMap = {
      'username': user.username,
      'wallet': user.wallet,
      'signInMsg': dePlanSignInData.signInMsg,
      'signature': dePlanSignInData.signature,
    };

    if (user.avatarToSet != null) {
      userMap['avatar'] =
          MultipartFile.fromBytes(user.avatarToSet!, filename: 'avatar');
    }

    FormData payload = FormData.fromMap(userMap);

    final response = await client.post(
      '/auth/signup/deplan',
      data: payload,
      options: Options(contentType: 'multipart/form-data'),
    );
    await appStorage.write('jwt_token', response.data['token']);
    return response;
  }

  Future<Response> signinDeplan(DePlanSignInData dePlanSignInData) async {
    final Map<String, dynamic> data = {
      'wallet': dePlanSignInData.wallet,
      'signInMsg': dePlanSignInData.signInMsg,
      'signature': dePlanSignInData.signature,
    };

    final response = await client.post(
      '/auth/signin/deplan',
      data: data,
    );
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
  }

  initWallet() async {
    final sk = await appStorage.getValue('sk');
    _keyPair = await CryptoUtils.keypairFromSk(sk ?? '');
  }

  Future<String> signTxn(String txn) async {
    final tx = SignedTx.decode(txn);
    final signedTx = SignedTx(
      compiledMessage: tx.compiledMessage,
      signatures: List.from(tx.signatures)
        ..removeWhere((signature) => signature.publicKey == _keyPair?.publicKey)
        ..add(
          await _keyPair!.sign(tx.compiledMessage.toByteArray()),
        ),
    );
    return signedTx.encode();
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    final sk = await getKey();
    return CryptoUtils.encrypt(
      base64Encode(base58decode(sk).take(32).toList()),
      data,
    );
  }

  Future<Uint8List> decrypt(Uint8List data) async {
    final sk = await getKey();
    return CryptoUtils.decrypt(
      base64Encode(base58decode(sk).take(32).toList()),
      data,
    );
  }
}

final authApi = _AuthApi();
