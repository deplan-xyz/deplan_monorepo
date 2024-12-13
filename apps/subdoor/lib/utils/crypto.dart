import 'dart:convert';

import 'package:bip39/bip39.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

class CryptoUtils {
  static String generateEntropy() {
    final mnemonic = generateMnemonic();
    return mnemonicToEntropy(mnemonic);
  }

  static Future<Ed25519HDKeyPair> generateKeypair(String entropy) {
    final mnemonic = entropyToMnemonic(entropy);
    final seed = mnemonicToSeed(mnemonic);
    return compute(
      (seed) async {
        const hdPath = "m/44'/501'/0'/0'";

        return Ed25519HDKeyPair.fromSeedWithHdPath(seed: seed, hdPath: hdPath);
      },
      seed,
    );
  }

  static Future<String> getSecretKey(Ed25519HDKeyPair keyPair) async {
    final data = await keyPair.extract();
    final secretBytes = Uint8List(64);
    secretBytes.setAll(0, data.bytes);
    secretBytes.setAll(32, keyPair.publicKey.toByteArray());
    return base58encode(secretBytes);
  }

  static Future<String> getPassword(String seed) async {
    return compute(
      (message) async {
        final data =
            await ED25519_HD_KEY.getMasterKeyFromSeed(base64Decode(message));
        return base64Encode(data.key);
      },
      seed,
    );
  }

  static Future<Ed25519HDKeyPair> keypairFromSk(String sk) {
    return compute(
      (message) => Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: base58decode(message).take(32).toList(),
      ),
      sk,
    );
  }
}
