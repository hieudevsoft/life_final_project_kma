import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/friend_model.dart';
import 'package:uvid/domain/models/profile.dart';

class NotificationManager extends ChangeNotifier {
  NotificationManager._() {
    _loadInitData();
  }
  static get _instance => NotificationManager._();
  factory NotificationManager() {
    return _instance;
  }

  DatabaseReference _ref = FirebaseDatabase.instance.ref();
  Profile? _user = null;
  List<FriendModel>? waitingAccepts = null;

  void _loadInitData() async {
    fetchWaittingFriendAccept();
  }

  fetchWaittingFriendAccept() async {
    if (_user == null) {
      _user = await LocalStorage().getProfile();
    }
    if (_user != null) {
      _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).once().then(
        (DatabaseEvent databaseEvent) {
          final snapshot = databaseEvent.snapshot;
          if (snapshot.exists) {
            if (snapshot.children.length == 1) {
              final data = snapshot.children.first.value;
              if (data is Map<Object?, Object?>) {
                try {
                  final castMap = Map.castFrom<Object?, Object?, String, dynamic>(data);
                  final friend = FriendModel.fromMap(castMap);
                  if (waitingAccepts == null) {
                    waitingAccepts = [];
                  }
                  waitingAccepts!.add(friend);
                  notifyListeners();
                } catch (e) {}
              }
            }
          }
          if (waitingAccepts == null) {
            waitingAccepts = [];
            notifyListeners();
          }
        },
      );
    } else {
      waitingAccepts = [];
      notifyListeners();
    }
  }

  deleteWaitingFriendAccept(String userId) async {
    if (waitingAccepts == null || waitingAccepts!.isEmpty) return;
    final cachedContacts = await LocalStorage().getCachedContacts();
    final isExist = cachedContacts.indexWhere((element) => element.userId == userId) != -1;
    if (isExist) {
      final contact = cachedContacts.firstWhere((element) => element.userId == userId);
      await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).remove();
      waitingAccepts!.removeWhere((element) => element.userId == userId);
      LocalStorage().updateContactLocal(contact.copyWith(friendStatus: 0));
      notifyListeners();
    }
  }

  acceptWaitingFriendAccept(String userId) async {
    if (waitingAccepts == null || waitingAccepts!.isEmpty) return;
    final cachedContacts = await LocalStorage().getCachedContacts();
    final isExist = cachedContacts.indexWhere((element) => element.userId == userId) != -1;
    if (isExist) {
      final contact = cachedContacts.firstWhere((element) => element.userId == userId);
      await _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).set({
        'time': getTimeNowInWholeMilliseconds(),
      });
      await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).remove();
      waitingAccepts!.removeWhere((element) => element.userId == userId);
      LocalStorage().updateContactLocal(contact.copyWith(friendStatus: 0));
      notifyListeners();
    }
  }
}
