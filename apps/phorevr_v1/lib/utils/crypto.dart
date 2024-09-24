import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:flutter/foundation.dart';
import 'package:phorevr/utils/js_crypto.dart' as js_crypto;
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

const IV_LENGTH = 16;

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

  static Future<Uint8List> encrypt(String base64Key, Uint8List data) async {
    final dataString = base64Encode(data);
    final key = encryption.Key.fromBase64(base64Key);
    final iv = encryption.IV.fromLength(IV_LENGTH);

    if (kIsWeb) {
      final encrypted =
          await js_crypto.encrypt(dataString, base64Key, iv.base64);
      return Uint8List.fromList(encrypted.codeUnits);
    }
    return compute<void, Uint8List>(
      (_) {
        final encrypter = encryption.Encrypter(encryption.AES(key));
        final encrypted = encrypter.encrypt(dataString, iv: iv);

        return (BytesBuilder()
              ..add(iv.bytes)
              ..add(encrypted.bytes))
            .toBytes();
      },
      null,
    );
  }

  static Future<Uint8List> decrypt(String base64Key, Uint8List data) async {
    final ivBytes = data.sublist(0, IV_LENGTH);
    final dataBytes = data.sublist(IV_LENGTH);

    if (kIsWeb) {
      final decrypted = await js_crypto.decrypt(
        String.fromCharCodes(dataBytes),
        base64Key,
        base64Encode(ivBytes),
      );
      return base64Decode(decrypted);
    }
    return compute<void, Uint8List>(
      (_) {
        final key = encryption.Key.fromBase64(base64Key);
        final iv = encryption.IV(ivBytes);
        final encrypter = encryption.Encrypter(encryption.AES(key));
        final encrypted = encryption.Encrypted(dataBytes);
        final decrypted = encrypter.decrypt(encrypted, iv: iv);

        return base64Decode(decrypted);
      },
      null,
    );
  }
}
