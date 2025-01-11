import 'dart:convert';
import 'dart:typed_data';

import 'package:solana/base58.dart';
import 'package:subdoor/wallet/types/chain.dart';
import 'package:subdoor/wallet/types/signin_response.dart';
import 'package:subdoor/wallet/abstract/wallet.dart';
import 'package:subdoor/wallet/web/solana/js_wallet_api/js_wallet_api.dart'
    as js_wallet_api;

class SolanaWebWallet implements Wallet {
  @override
  Chain chain = Chain.solana;

  @override
  Future<SignInResponse> signIn(String walletName) async {
    final result = await js_wallet_api.signIn(walletName);

    final signature =
        Uint8List.fromList(List.from(result['signature']['data']));
    final signatureStr = base58encode(signature);
    final msg = Uint8List.fromList(List.from(result['message']['data']));
    final msgStr = utf8.decode(msg);
    final address = result['address'];

    return SignInResponse(
      signature: signatureStr,
      message: msgStr,
      address: address,
    );
  }

  @override
  Future<String> signTransaction(String tx) async {
    return await js_wallet_api.signTransaction(tx);
  }
}
