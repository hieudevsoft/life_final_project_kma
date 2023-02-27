import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/profile.dart';

enum StateData { ADDED, DELETED }

class FriendManager extends ChangeNotifier {
  FriendManager._() {
    _loadInitData();
  }
  static get _instance => FriendManager._();
  factory FriendManager() {
    return _instance;
  }

  final _ref = FirebaseDatabase.instance.ref();
  final collectionUser = FirebaseFirestore.instance.collection(USER_COLLECTION);
  final StreamController<Map<String, StateData>> friendUniqueIdsController = StreamController.broadcast();
  final List<String> friendUniqueIds = [];
  List<Profile>? friends = null;
  Profile? _user = null;
  void _loadInitData() async {
    _user = await LocalStorage().getProfile();
    _fetchFriends();
  }

  void _fetchFriends() async {
    if (_user == null) return;
    final cachedFriendIds = await LocalStorage().getCachedFriendIds();
    if (cachedFriendIds.isNotEmpty) {
      cachedFriendIds.forEach((element) {
        friendUniqueIdsController.add({element: StateData.ADDED});
      });
    }
    _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).onChildAdded.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        if (!cachedFriendIds.contains(event.snapshot.key)) {
          friendUniqueIdsController.sink.add({event.snapshot.key!: StateData.ADDED});
        }
      }
    });
  }

  listenFriend() {
    friendUniqueIdsController.stream.listen((event) async {
      if (event.entries.first.value == StateData.ADDED) {
        friendUniqueIds.add(event.entries.first.key);
        LocalStorage().updateCachedFriendIds(event.entries.first.key);
        final doc = await collectionUser.doc(event.entries.first.key).get();
        if (doc.exists) {
          if (doc.data() != null) {
            if (friends == null) friends = [];
            friends!.add(Profile.fromMap(doc.data()!));
            notifyListeners();
          }
        }
      } else {
        friendUniqueIds.remove(event.entries.first.key);
        LocalStorage().updateCachedFriendIds(event.entries.first.key, isRemoved: true);
        if (friends != null && friends!.isNotEmpty && _user != null) {
          friends!.removeAt(friends!.indexWhere((element) => element.uniqueId == event.entries.first.key));
          await _ref.child(_user!.uniqueId!).child(event.entries.first.key).remove();
          notifyListeners();
        }
      }
    });
  }

  void reloadFriend({
    VoidCallback? onUnAvailable = null,
  }) {
    if (_user == null || friendUniqueIds.isEmpty) {
      onUnAvailable?.call();
      return;
    }
    if (friends == null) friends = [];
    friends!.clear();
    friendUniqueIds.forEach((element) async {
      final doc = await collectionUser.doc(element).get();
      if (doc.exists) {
        if (doc.data() != null) {
          friends!.add(Profile.fromMap(doc.data()!));
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    friendUniqueIdsController.close();
  }
}
