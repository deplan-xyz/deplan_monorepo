import 'package:subdoor/wallet/types/chain.dart';
import 'package:subdoor/wallet/types/signin_response.dart';

abstract interface class Wallet {
  abstract Chain chain;

  Future<SignInResponse> signIn(String walletName);

  Future<String> signTransaction(String tx);
}
