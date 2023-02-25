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
  bool isLoadingSearch = false;
  void search(String query) async {
    isLoadingSearch = true;
    contactsAvailable.clear();
    notifyListeners();
    if (query.isEmpty) return;
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
      snapshots.docs.forEach((element) {
        if (element.exists) {
          final profile = Profile.fromMap(element.data());
          final contact = profile.toContactModel();
          final isMe = profile.uniqueId == _user?.uniqueId;
          final isOnCached = contactsAvailable.indexWhere((element) => element.userId == contact.userId) != -1;
          if (!isMe && !isOnCached) {
            print(contact.name);
            contactsAvailable.add(contact);
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
      //TODO remove friend
      onComplete?.call();
    } else if (friendStatus == 0) {
      if (contactModel.keyId != null) {
        await _ref.child(contactModel.keyId!).child(_user!.uniqueId.toString()).remove();
        onComplete?.call();
      }
      onComplete?.call();
    } else {
      if (contactModel.keyId != null) {
        await _ref.child(contactModel.keyId!).child(_user!.uniqueId.toString()).update({
          'userId': contactModel.userId,
          'name': contactModel.name,
          'image': contactModel.urlLinkImage,
          'description': contactModel.description,
          'time': getTimeNowInWholeMilliseconds(),
        });
        onComplete?.call();
      }
    }
    notifyListeners();
  }
}
