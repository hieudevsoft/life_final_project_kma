import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/contact_model.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/utils/notifications.dart';

class FriendManager extends ChangeNotifier {
  FriendManager._();
  static get _instance => FriendManager._();
  factory FriendManager() {
    return _instance;
  }

  final _ref = FirebaseDatabase.instance.ref();
  final collectionUser = FirebaseFirestore.instance.collection(USER_COLLECTION);
  final List<String> friendUniqueIds = [];
  List<Profile>? friends = null;
  List<ContactModel> waittingsCalling = [];
  Profile? _user = null;
  get user => _user;
  void loadInitData() async {
    _user = await LocalStorage().getProfile();
    _fetchFriends();
  }

  void _fetchFriends() async {
    if (_user == null) {
      friends = [];
      notifyListeners();
      return;
    }
    final cachedFriendIds = await LocalStorage().getCachedFriendIds();
    if (friends == null) {
      friends = [];
    } else {
      friends!.clear();
    }
    if (cachedFriendIds.isNotEmpty) {
      cachedFriendIds.forEach((element) async {
        final doc = await collectionUser.doc(element).get();
        if (doc.exists) {
          if (doc.data() != null) {
            friends!.add(Profile.fromMap(doc.data()!));
            notifyListeners();
          }
        }
      });
    } else {
      friends = [];
      notifyListeners();
    }
    _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).onChildAdded.listen((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        if (!cachedFriendIds.contains(event.snapshot.key)) {
          final key = event.snapshot.key ?? '';
          friendUniqueIds.add(key);
          LocalStorage().updateCachedFriendIds(key);
          final doc = await collectionUser.doc(key).get();
          if (doc.exists) {
            if (doc.data() != null) {
              if (friends == null) friends = [];
              friends!.add(Profile.fromMap(doc.data()!));
              notifyListeners();
            }
          }
        }
      }
    });
    _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).onChildRemoved.listen((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        if (!cachedFriendIds.contains(event.snapshot.key)) {
          final key = event.snapshot.key ?? '';
          friendUniqueIds.remove(key);
          LocalStorage().updateCachedFriendIds(key, isRemoved: true);
          if (friends != null && friends!.isNotEmpty && _user != null) {
            friends!.removeAt(friends!.indexWhere((element) => element.uniqueId == key));
            await _ref.child(FRIEND_COLLECTION).child(key).child(_user!.uniqueId!).remove();
            notifyListeners();
          }
        }
      }
    });
  }

  void reloadFriend({
    VoidCallback? onUnAvailable = null,
  }) {
    if (_user == null) {
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

  void removeFriend(
    Profile profile,
    Function onComplete,
  ) async {
    if (_user == null) return;
    await _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).child(profile.uniqueId!).remove();
    onComplete.call();
    removeFriendLocal(profile.uniqueId!);
  }

  void removeFriendLocal(String uniqueId) {
    if (friends == null || friends!.isEmpty) {
      return;
    }
    friends!.removeWhere((element) => element.uniqueId == uniqueId);
    friendUniqueIds.removeWhere((element) => element == uniqueId);
    LocalStorage().updateCachedFriendIds(uniqueId, isRemoved: true);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Profile? _profileTrackCall = null;
  void trackCall({
    Function(Profile)? onCalling = null,
    Function()? onCallingCancelled = null,
    Function(String meetingId)? onAcceptCalling = null,
  }) {
    LocalStorage().getProfile().then((userCached) {
      if (_user == null && userCached != null) {
        _user = userCached;
      }
      if (userCached?.uniqueId == null) return;
      _ref.child(SENDER_CALL_COLLECTION).child(userCached!.uniqueId!).once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          if (snapshot.value is String) {
            try {
              final profile = Profile.fromJson(snapshot.value as String);
              _profileTrackCall = profile;
              onCalling?.call(profile);
            } on FormatException catch (e) {}
          }
        }
      });

      _ref.child(SENDER_CALL_COLLECTION).onChildRemoved.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          if (snapshot.key == userCached.uniqueId!) {
            onCallingCancelled?.call();
          }
        }
      });

      LocalStorage().getPartnerId().then((partnerId) {
        _ref.child(MEETING_COOLECTION).onChildAdded.listen((event) {
          final snapshot = event.snapshot;
          if (snapshot.key == partnerId + user.uniqueId && partnerId.isNotEmpty) {
            onAcceptCalling?.call(partnerId + user.uniqueId);
            LocalStorage().setPartnerIdCalling('');
          }
        });
      });
    });
  }

  bool _isCalling = false;
  callToFriend(
    Profile profile,
    VoidCallback onCallSuccessfully,
    Function(String meetingId) onAcceptCalling,
  ) {
    if (_isCalling || _user?.uniqueId == null) return;
    _isCalling = true;
    final partnerId = profile.uniqueId!;
    LocalStorage().setPartnerIdCalling(partnerId);
    _ref.child(SENDER_CALL_COLLECTION).child(_user!.uniqueId!).set(profile.toJson()).then((value) {
      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(partnerId).child(_user!.uniqueId!).set(_user!.toContactModel().toJson());
      _ref.child(MEETING_COOLECTION).child(partnerId + user.uniqueId).remove().then((value) {
        _ref.child(MEETING_COOLECTION).onChildAdded.listen((event) async {
          final snapshot = event.snapshot;
          final partnerIdCached = await LocalStorage().getPartnerId();
          if (snapshot.key == partnerId + user.uniqueId && partnerIdCached.isEmpty) {
            LocalStorage().setPartnerIdCalling('');
            onAcceptCalling.call(partnerId + user.uniqueId);
          }
        });
      });
      _profileTrackCall = profile;
      _isCalling = false;
      onCallSuccessfully.call();
    }).onError((error, stackTrace) {
      _isCalling = false;
    });
  }

  bool _isCancellingCall = false;
  cancelCalling() {
    if (_isCancellingCall || _user?.uniqueId == null) return;
    _isCancellingCall = true;
    _ref.child(SENDER_CALL_COLLECTION).child(_user!.uniqueId!).remove().then((value) {
      if (_profileTrackCall != null) {
        _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(_profileTrackCall!.uniqueId!).child(_user!.uniqueId!).remove();
        _isCancellingCall = false;
      }
    }).onError((error, stackTrace) {
      _isCancellingCall = false;
    });
  }

  bool _isRemovingCall = false;
  removingCall(String keyId, VoidCallback onComplete) {
    if (_isRemovingCall || _user?.uniqueId == null) return;
    _isRemovingCall = true;
    _ref.child(SENDER_CALL_COLLECTION).child(keyId).remove().then((value) {
      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(_user!.uniqueId!).child(keyId).remove().then((value) {
        _isRemovingCall = false;
        waittingsCalling.removeWhere((element) => element.keyId == keyId);
        if (waittingsCalling.isEmpty) onComplete.call();
        notifyListeners();
      });
    }).onError((error, stackTrace) {
      _isRemovingCall = false;
    });
  }

  bool _isAcceptCalling = false;
  acceptCalling(String keyId, Function(String meetingId) joinMeeting) {
    if (_isAcceptCalling || _user?.uniqueId == null) return;
    _isAcceptCalling = true;
    _ref.child(SENDER_CALL_COLLECTION).child(keyId).remove().then((value) {
      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(_user!.uniqueId!).remove().then((value) {
        _ref.child(MEETING_COOLECTION).child(_user!.uniqueId! + keyId).set(getTimeNowInWholeMilliseconds());
        _isAcceptCalling = false;
        waittingsCalling.clear();
        if (waittingsCalling.isEmpty) joinMeeting.call(_user!.uniqueId! + keyId);
        notifyListeners();
      });
    }).onError((error, stackTrace) {
      _isAcceptCalling = false;
    });
  }

  bool isHavingCallingCalled = false;
  void trackOnReceivedCalling(VoidCallback onHaveCalling, VoidCallback onCompleteTracking) {
    LocalStorage().getProfile().then((userCached) {
      if (_user == null && userCached != null) {
        _user = userCached;
      }
      if (waittingsCalling.isNotEmpty) waittingsCalling.clear;

      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(_user!.uniqueId!).onChildAdded.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          if (snapshot.value is String) {
            try {
              if (!isHavingCallingCalled) {
                isHavingCallingCalled = true;
                onHaveCalling.call();
              }
              final contactModel = ContactModel.fromJson(snapshot.value as String);
              if (!waittingsCalling.contains(contactModel)) {
                waittingsCalling.add(contactModel);
              }
              NotificationManager().showBasicNotification(
                title: "Life notification",
                body: "You have people calling",
              );
              notifyListeners();
            } on FormatException catch (e) {}
          }
        }
      });

      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).child(_user!.uniqueId!).onChildRemoved.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          if (snapshot.value is String) {
            try {
              final contactModel = ContactModel.fromJson(snapshot.value as String);
              if (waittingsCalling.contains(contactModel)) {
                waittingsCalling.remove(contactModel);
              }
              notifyListeners();
            } on FormatException catch (e) {}
          }
        }
      });

      _ref.child(WAITING_ACCEPT_CALL_COLLECTION).onChildRemoved.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          if (snapshot.value is Map<Object?, Object?> && snapshot.key != null && snapshot.key == userCached!.uniqueId!) {
            isHavingCallingCalled = false;
            onCompleteTracking.call();
          }
        }
      });
    });
  }
}
