import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/friend_model.dart';
import 'package:uvid/domain/models/profile.dart';

class NotificationManager extends ChangeNotifier {
  NotificationManager._();
  static get _instance => NotificationManager._();
  factory NotificationManager() {
    return _instance;
  }

  DatabaseReference _ref = FirebaseDatabase.instance.ref();
  Profile? _user = null;
  List<FriendModel>? waitingAccepts = null;

  void loadInitData() async {
    fetchWaittingFriendAccept();
  }

  fetchWaittingFriendAccept() async {
    if (_user == null) {
      _user = await LocalStorage().getProfile();
    }
    if (_user != null) {
      if (waitingAccepts == null) {
        waitingAccepts = [];
      } else {
        waitingAccepts!.clear();
      }
      _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).once().then(
        (DatabaseEvent databaseEvent) {
          final snapshot = databaseEvent.snapshot;
          if (snapshot.exists) {
            if (snapshot.children.length > 0) {
              snapshot.children.forEach((snapshot) {
                if (snapshot.value is Map<Object?, Object?>) {
                  try {
                    final castMap = Map.castFrom<Object?, Object?, String, dynamic>(snapshot.value as Map<Object?, Object?>);
                    final friend = FriendModel.fromMap(castMap);
                    waitingAccepts!.add(friend);
                    notifyListeners();
                  } catch (e) {
                    print(e);
                  }
                }
              });
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
    final isExistInWaittingAccepts =
        waitingAccepts!.map((e) => e.toContactModel()).toList().indexWhere((element) => element.userId == userId) != -1;
    if (isExist || isExistInWaittingAccepts) {
      final contact = isExist
          ? cachedContacts.firstWhere((element) => element.userId == userId)
          : waitingAccepts!.map((e) => e.toContactModel()).toList().firstWhere((element) => element.userId == userId);
      await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).remove();
      await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(contact.keyId!).child(_user!.uniqueId!).remove();
      waitingAccepts!.removeWhere((element) => element.userId == userId);
      LocalStorage().updateContactLocal(contact.copyWith(friendStatus: 0));
      notifyListeners();
    }
  }

  acceptWaitingFriendAccept(String userId) async {
    if (waitingAccepts == null || waitingAccepts!.isEmpty) return;
    final cachedContacts = await LocalStorage().getCachedContacts();
    final isExist = cachedContacts.indexWhere((element) => element.userId == userId) != -1;
    final isExistInWaittingAccepts =
        waitingAccepts!.map((e) => e.toContactModel()).toList().indexWhere((element) => element.userId == userId) != -1;
    if (isExist || isExistInWaittingAccepts) {
      final contact = isExist
          ? cachedContacts.firstWhere((element) => element.userId == userId)
          : waitingAccepts!.map((e) => e.toContactModel()).toList().firstWhere((element) => element.userId == userId);

      await _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).set({
        'time': getTimeNowInWholeMilliseconds(),
      });
      await _ref.child(FRIEND_COLLECTION).child(contact.keyId!).child(_user!.uniqueId!).set({
        'time': getTimeNowInWholeMilliseconds(),
      });
      await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).remove();
      waitingAccepts!.removeWhere((element) => element.userId == userId);
      LocalStorage().updateContactLocal(contact.copyWith(friendStatus: 0));
      notifyListeners();
    }
  }
}
