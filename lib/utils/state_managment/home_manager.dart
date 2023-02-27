import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/notification_mode.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/domain/models/video_mode.dart';
import 'package:uvid/utils/connectivity.dart';

class HomeManager extends ChangeNotifier {
  HomeManager._internal() {
    _networkConnectivity.initialise();
    _networkConnectivity.connectivityStream.listen((source) {
      _source = source;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          statusInternet = _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          break;
        case ConnectivityResult.wifi:
          statusInternet = _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          break;
        case ConnectivityResult.none:
          statusInternet = _source.values.toList()[0] ? 'Online' : 'Offline';
          break;
        default:
          statusInternet = 'Offline';
      }
      ;
      notifyListeners();
    });
    loadFutureData();
  }
  static final _instance = HomeManager._internal();
  factory HomeManager() {
    return _instance;
  }

  Map _source = {ConnectivityResult.none: false};
  final UvidAppConnectivity _networkConnectivity = UvidAppConnectivity();
  String statusInternet = '';

  Profile? profile = null;
  void setProfile(Profile? newProfile) {
    LocalStorage().setProfile(newProfile);
    if (profile == null) {
      LocalStorage().setAccessToken(null);
    }
    profile = newProfile;
    notifyListeners();
  }

  Future loadFutureData() async {
    profile = await LocalStorage().getProfile();
  }

  int _page = 0;
  int get page => _page;
  onPageChanged(int page) {
    if (page == _page) return;
    _page = page;
    notifyListeners();
  }

  bool _isMuteAudio = false;
  bool get isMuteAudio => _isMuteAudio;
  onChangeMuteAudio(AudioMode audioMode) {
    final isMute = audioMode == AudioMode.OFF;
    if (isMute == _isMuteAudio) return;
    _isMuteAudio = isMute;
    LocalStorage().setAudioMode(audioMode);
    notifyListeners();
  }

  bool _isMuteVideo = false;
  bool get isMuteVideo => _isMuteVideo;
  onChangeMuteVideo(VideoMode videoMode) {
    final isMute = videoMode == VideoMode.OFF;
    if (isMute == _isMuteVideo) return;
    _isMuteVideo = isMute;
    LocalStorage().setVideoMode(videoMode);
    notifyListeners();
  }

  bool _isMuteNotification = false;
  bool get isMuteNotification => _isMuteNotification;
  onChangeMuteNotification(NotificationMode notificationMode) {
    final isMute = notificationMode == NotificationMode.OFF;
    if (isMute == _isMuteNotification) return;
    _isMuteNotification = isMute;
    LocalStorage().setNotificationMode(notificationMode);
    notifyListeners();
  }

  ContactMode _searchContactMode = ContactMode.NAME;
  ContactMode get searchContactMode => _searchContactMode;
  onChangeSearchContactMode(ContactMode searchContactMode) {
    if (searchContactMode == _searchContactMode) return;
    _searchContactMode = searchContactMode;
    LocalStorage().setContactsMode(searchContactMode);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _networkConnectivity.disposeStream();
  }
}
