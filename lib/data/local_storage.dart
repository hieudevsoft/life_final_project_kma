import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/domain/models/notification_mode.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/domain/models/video_mode.dart';

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

  Future<AudioMode> getAudioMode() async {
    final audioMode = await storage.read(key: 'audio_mode');
    if (audioMode == null) return AudioMode.ON;
    return AudioMode.values.firstWhere((element) => element.name == audioMode);
  }

  void setAudioMode(AudioMode audioMode) async {
    await storage.write(key: 'audio_mode', value: audioMode.name);
  }

  Future<NotificationMode> getNotificationMode() async {
    final notificationMode = await storage.read(key: 'notification_mode');
    if (notificationMode == null) return NotificationMode.ON;
    return NotificationMode.values.firstWhere((element) => element.name == notificationMode);
  }

  void setNotificationMode(NotificationMode notificationMode) async {
    await storage.write(key: 'notification_mode', value: notificationMode.name);
  }

  Future<VideoMode> getVideoMode() async {
    final videoMode = await storage.read(key: 'video_mode');
    if (videoMode == null) return VideoMode.ON;
    return VideoMode.values.firstWhere((element) => element.name == videoMode);
  }

  void setVideoMode(VideoMode videoMode) async {
    await storage.write(key: 'video_mode', value: videoMode.name);
  }

  Future<ContactMode> getSearchContactsMode() async {
    final contactMode = await storage.read(key: 'contacts_mode');
    if (contactMode == null) return ContactMode.NAME;
    return ContactMode.values.firstWhere((element) => element.name == contactMode);
  }

  void setContactsMode(ContactMode contactMode) async {
    await storage.write(key: 'contacts_mode', value: contactMode.name);
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

  Future<List<String>> getSearchContactHistories() async {
    final histories = await storage.read(key: 'search_contact_histories');
    if (histories == null) {
      return [];
    }
    final result = (json.decode(histories) as List<dynamic>).map((e) => e.toString()).toList();
    return result;
  }

  void setSearchContactHistories(List<String> histories) async {
    if (histories.isEmpty) {
      await storage.delete(key: 'search_contact_histories');
    } else {
      await storage.write(key: 'search_contact_histories', value: json.encode(histories));
    }
  }
}
