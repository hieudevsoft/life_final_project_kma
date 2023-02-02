import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uvid/common/constants.dart';

abstract class AppEncrypter {
  static final _encrypter = Encrypter(AES(keyAes, mode: mode));

  static String enCryptWithAes(String content) {
    return _encrypter.encrypt(content, iv: iv).base64;
  }

  static String deCryptWithAes(String content) {
    return _encrypter.decrypt64(content, iv: iv);
  }

  static Future<T> _parseKeyFromFile<T extends RSAAsymmetricKey>(String filename) async {
    final key = await rootBundle.loadString(filename);
    final parser = RSAKeyParser();
    return parser.parse(key) as T;
  }

  static Future<String> enCryptWitRSA(String content) async {
    final publicKey = await _parseKeyFromFile<RSAPublicKey>('keys/public.pem');
    final privKey = await _parseKeyFromFile<RSAPrivateKey>('keys/private.pem');
    return Encrypter(RSA(publicKey: publicKey, privateKey: privKey)).encrypt(content).base64;
  }

  static Future<String> deCryptWitRSA(String content) async {
    final publicKey = await _parseKeyFromFile<RSAPublicKey>('keys/public.pem');
    final privKey = await _parseKeyFromFile<RSAPrivateKey>('keys/private.pem');
    return Encrypter(RSA(publicKey: publicKey, privateKey: privKey)).decrypt64(content);
  }
}
