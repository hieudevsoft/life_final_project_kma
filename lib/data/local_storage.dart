import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/domain/models/profile.dart';

class LocalStorage {
  LocalStorage._();
  static get _instance => LocalStorage._();
  factory LocalStorage() {
    return _instance;
  }
  final storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<bool> getIsDarkMode() async {
    return await storage.read(key: 'is_dark_mode') == 'true';
  }

  void setIsDarkMode(bool isDarkmode) async {
    await storage.write(key: 'is_dark_mode', value: isDarkmode.toString());
  }

  Future<LanguageType> getLanguage() async {
    final language = await storage.read(key: 'language');
    if (language == null) return LanguageType.VI;
    return LanguageType.values.firstWhere((element) => element.name == language);
  }

  void setLanguage(LanguageType languageType) async {
    await storage.write(key: 'language', value: languageType.name);
  }

  Future<Profile?> getProfile() async {
    final jsonProfile = await storage.read(key: 'profile');
    if (jsonProfile == null) return null;
    return Profile.fromJson(jsonProfile);
  }

  void setProfile(Profile? profile) async {
    if (profile == null) {
      await storage.delete(key: 'profile');
    } else {
      final value = profile.toJson();
      await storage.write(key: 'profile', value: value);
    }
  }

  Future<String?> getAccessToken() async {
    final accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  void setAccessToken(String? accessToken) async {
    if (accessToken == null) {
      await storage.delete(key: 'access_token');
    } else {
      await storage.write(key: 'access_token', value: accessToken);
    }
  }
}
