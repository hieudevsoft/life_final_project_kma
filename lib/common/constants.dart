import 'package:encrypt/encrypt.dart' as encrypt;

const String USER_COLLECTION = 'user';
const String FRIEND_COLLECTION = 'friend';
const String APP_NAME = 'Life';
final keyAes = encrypt.Key.fromBase64('Q1aOOcpDHh8Gn3oSCPP8ZTYOaB1HpwM8kLJfbK0cAVE=');
final iv = encrypt.IV.fromBase64('ZsM/zT2AxQytn3KgxJPivw==');
const mode = encrypt.AESMode.cbc;
