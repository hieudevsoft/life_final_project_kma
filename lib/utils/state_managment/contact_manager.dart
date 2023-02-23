import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/data/local_storage.dart';
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

  FilterSearchModel? _filterSearchModel = null;
  FilterSearchModel? get filterSearchModel => _filterSearchModel;
  void setFilterSearchModel(FilterSearchModel filterSearchModel) {
    _filterSearchModel = filterSearchModel;
    LocalStorage().setSearchContactHistories(filterSearchModel.orgList);
    notifyListeners();
  }

  Profile? _user = null;
  List<ContactModel> contactsAvailable = [];
  void loadInitData() async {
    final histories = await LocalStorage().getSearchContactHistories();
    _user = await LocalStorage().getProfile();
    setFilterSearchModel(FilterSearchModel(orgList: histories));
  }

  void search(String query) async {
    contactsAvailable.clear();
    notifyListeners();
    final filed = LocalStorage().getSearchContactsMode();
    _fireStore
        .collection(USER_COLLECTION)
        .where('name', isGreaterThan: query.toUpperCase())
        .where('name', isLessThan: query.toLowerCase() + '\uf8ff')
        .get()
        .then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docChanges.forEach((element) {
          if (element.doc.exists) {
            if (element.doc.data() is Map<String, dynamic>) {
              final profile = Profile.fromMap(element.doc.data() as Map<String, dynamic>);
              contactsAvailable.add(profile.toContactModel());
              notifyListeners();
            }
          }
        });
      },
    );
  }
}
