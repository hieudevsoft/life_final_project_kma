import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/contact_model.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/ui/widgets/floating_search_bar.dart';

class ContactManager extends ChangeNotifier {
  ContactManager._internal() {
    loadInitData();
  }
  static final _instance = ContactManager._internal();
  factory ContactManager() {
    return _instance;
  }

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  FilterSearchModel? _filterSearchModel = null;
  FilterSearchModel? get filterSearchModel => _filterSearchModel;
  void setFilterSearchModel(FilterSearchModel filterSearchModel) {
    _filterSearchModel = filterSearchModel;
    LocalStorage().setSearchContactHistories(filterSearchModel.orgList);
    notifyListeners();
  }

  void resetFilterSearchModel() {
    _filterSearchModel = _filterSearchModel?.copyWith(searchTerm: '');
    contactsAvailable.clear();
    notifyListeners();
  }

  Profile? _user = null;
  get user => _user;
  bool isGuessAccount = false;
  Future<bool> checkGuessAccount() async {
    final accessToken = await LocalStorage().getAccessToken();
    return accessToken == null || accessToken.isEmpty;
  }

  void loadInitData() async {
    final histories = await LocalStorage().getSearchContactHistories();
    _user = await LocalStorage().getProfile();
    isGuessAccount = await checkGuessAccount() || _user == null;
    setFilterSearchModel(FilterSearchModel(orgList: histories));
  }

  List<ContactModel> contactsAvailable = [];

  void resetContactsAvailable() {
    contactsAvailable = [];
    notifyListeners();
  }

  bool isLoadingSearch = false;
  void search(String query) async {
    isLoadingSearch = true;
    contactsAvailable.clear();
    notifyListeners();
    if (query.isEmpty) {
      isLoadingSearch = false;
      notifyListeners();
      return;
    }
    final searchContactMode = await LocalStorage().getSearchContactsMode();
    final field = searchContactMode == ContactMode.NAME
        ? 'name'
        : searchContactMode == ContactMode.EMAIL
            ? 'email'
            : 'phone';
    final cachedContacts = await LocalStorage().getCachedContacts();
    cachedContacts.forEach((element) {
      if (element.name != null && element.name!.toLowerCase().contains(query.toLowerCase())) {
        contactsAvailable.add(element);
        if (isLoadingSearch) {
          isLoadingSearch = false;
        }
        notifyListeners();
      } else if (element.description != null) {
        if (element.description!.toLowerCase().contains(query.toLowerCase())) {
          contactsAvailable.add(element);
          if (isLoadingSearch) {
            isLoadingSearch = false;
          }
          notifyListeners();
        }
      }
    });
    final QuerySnapshot<Map<String, dynamic>> snapshots = await _fireStore
        .collection(USER_COLLECTION)
        .orderBy(field)
        .startAt([query.toUpperCase()]).endAt([query.toLowerCase() + '\uf8ff']).get();

    if (snapshots.docs.isNotEmpty) {
      snapshots.docs.forEach((element) async {
        print(element.data());
        if (element.exists) {
          final profile = Profile.fromMap(element.data());
          ContactModel contact = profile.toContactModel();
          final friend = await _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).child(contact.keyId!).get();
          if (friend.exists) {
            contact = contact.copyWith(friendStatus: 1);
          }
          final isMe = profile.uniqueId == _user?.uniqueId;
          final isOnCached = contactsAvailable.indexWhere((element) => element == contact) != -1;
          if (!isMe && !isOnCached) {
            final indexSameId = contactsAvailable.indexWhere((element) => element.keyId == contact.keyId);
            if (indexSameId != -1) {
              contactsAvailable[indexSameId] = contact;
            } else {
              contactsAvailable.add(contact);
            }
            LocalStorage().updateContactLocal(contact);
            notifyListeners();
          }
        }
      });
    }
    if (isLoadingSearch) {
      isLoadingSearch = false;
      notifyListeners();
    }
  }

  void triggerHandleFriend(
    ContactModel contactModel,
    int friendStatus, {
    bool isRemoveFriend = false,
    Function? onComplete = null,
  }) async {
    contactModel = contactModel.copyWith(friendStatus: friendStatus);
    LocalStorage().updateContactLocal(contactModel);
    final index = contactsAvailable.indexWhere((element) => contactModel.userId == element.userId);
    contactsAvailable[index] = contactModel;

    if (isRemoveFriend && friendStatus == 0) {
      await _ref.child(FRIEND_COLLECTION).child(_user!.uniqueId!).child(contactModel.keyId!).remove();
      final index = contactsAvailable.indexOf(contactModel);
      contactsAvailable[index] = contactModel.copyWith(friendStatus: 0);
      onComplete?.call();
    } else if (friendStatus == 0) {
      if (contactModel.keyId != null) {
        await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(contactModel.keyId!).child(_user!.uniqueId.toString()).remove();
        onComplete?.call();
      }
      onComplete?.call();
    } else {
      if (contactModel.keyId != null) {
        await _ref.child(WAITING_ACCEPT_FRIEND_COLLECTION).child(contactModel.keyId!).child(_user!.uniqueId.toString()).update({
          'keyId': _user!.uniqueId!,
          'userId': _user!.userId,
          'name': _user!.name,
          'image': _user!.photoUrl,
          'description': _user!.email == null ? _user!.phoneNumber : _user!.email,
          'time': getTimeNowInWholeMilliseconds(),
        });
        onComplete?.call();
      }
    }
    notifyListeners();
  }
}
