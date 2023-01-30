import 'package:flutter/material.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/video_mode.dart';

class HomeManager extends ChangeNotifier {
  HomeManager._internal();
  static final _instance = HomeManager._internal();
  factory HomeManager() {
    return _instance;
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
    notifyListeners();
  }

  bool _isMuteVideo = false;
  bool get isMuteVideo => _isMuteVideo;
  onChangeMuteVideo(VideoMode videoMode) {
    final isMute = videoMode == VideoMode.OFF;
    if (isMute == _isMuteVideo) return;
    _isMuteVideo = isMute;
    notifyListeners();
  }
}
