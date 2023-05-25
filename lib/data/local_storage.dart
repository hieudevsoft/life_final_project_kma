import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/calendar_event_data_model.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/contact_model.dart';
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
      setAccessToken(null);
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

  Future<List<ContactModel>> getCachedContacts() async {
    final uniqueId = (await getProfile())?.uniqueId;
    final contacts = await storage.read(key: "${uniqueId}_cached_contacts");
    if (contacts == null) return [];
    final result = (json.decode(contacts) as List<dynamic>).map((e) => ContactModel.fromJson(e)).toList();
    return result;
  }

  void setCachedContacts(List<ContactModel> contacts) async {
    final uniqueId = (await getProfile())?.uniqueId;
    if (contacts.isEmpty) {
      return;
    }
    await storage.write(key: "${uniqueId}_cached_contacts", value: json.encode(contacts));
  }

  void updateContactLocal(ContactModel contactModel) async {
    final cachedContacts = await getCachedContacts();
    final index = cachedContacts.indexWhere((element) => element.userId == contactModel.userId);
    if (index == -1) {
      cachedContacts.add(contactModel);
    } else {
      cachedContacts[index] = contactModel;
    }
    setCachedContacts(cachedContacts);
  }

  Future<List<String>> getCachedFriendIds() async {
    final uniqueId = (await getProfile())?.uniqueId;
    final contacts = await storage.read(key: "{$uniqueId}_cached_friend_ids");
    if (contacts == null) return [];
    final result = (json.decode(contacts) as List<dynamic>).map((e) => e as String).toList();
    return result;
  }

  void setCachedFriendIds(List<String> contacts) async {
    final uniqueId = (await getProfile())?.uniqueId;
    if (contacts.isEmpty) {
      return;
    }
    await storage.write(key: "{$uniqueId}_cached_friend_ids", value: json.encode(contacts));
  }

  void updateCachedFriendIds(String uniqueId, {isRemoved = false}) async {
    final cachedFriendIds = await getCachedFriendIds();
    final index = cachedFriendIds.indexWhere((element) => element == uniqueId);
    if (index == -1) {
      cachedFriendIds.add(uniqueId);
    } else {
      if (isRemoved) {
        cachedFriendIds.removeAt(index);
      } else {
        cachedFriendIds[index] = uniqueId;
      }
    }
    setCachedFriendIds(cachedFriendIds);
  }

  void setPartnerIdCalling(String partnerID) async {
    if (partnerID.isEmpty) {
      return;
    }
    await storage.write(key: "partner_id", value: partnerID);
  }

  Future<String> getPartnerId() async {
    final partnerId = await storage.read(key: "partner_id");
    if (partnerId == null) return "";
    return partnerId;
  }

  void setEvents(String? uniqueId, List<CalendarEventDataModel> events) async {
    if (events.isEmpty) {
      return;
    }
    await storage.write(key: "${uniqueId}_events", value: json.encode(events));
  }

  Future<List<CalendarEventDataModel>> getEvents(String? uniqueId) async {
    final events = await storage.read(key: "${uniqueId}_events");
    if (events == null) return [];
    final List<CalendarEventDataModel> result =
        (json.decode(events) as List<dynamic>).map((e) => CalendarEventDataModel.fromJson(e)).toList();
    return result;
  }

  void updateEvent(String? uniqueId, CalendarEventDataModel calendarEventData) async {
    final events = await getEvents(uniqueId);
    final indexOfEvent = events
        .indexWhere((element) => element.startTime == calendarEventData.startTime && calendarEventData.date == element.date);
    if (indexOfEvent == -1) {
      events.add(calendarEventData);
    } else {
      events[indexOfEvent] = calendarEventData;
    }
    print(events);
    setEvents(uniqueId, events);
  }
}
