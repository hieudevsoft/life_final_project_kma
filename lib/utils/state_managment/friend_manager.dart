import 'package:flutter/material.dart';

class FriendManager extends ChangeNotifier {
  FriendManager._() {
    _loadInitData();
  }
  static get _instance => FriendManager._();
  factory FriendManager() {
    return _instance;
  }

  _loadInitData() {}
}
