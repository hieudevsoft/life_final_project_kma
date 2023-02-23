import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/ui/widgets/floating_search_bar.dart';

class FirestoreProviders {
  FirestoreProviders._internal();
  static final _instance = FirestoreProviders._internal();
  factory FirestoreProviders() {
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> get meetingsHistory =>
      _firestore.collection('users').doc(_auth.currentUser!.uid).collection('meetings').snapshots();
  void addToMeetingHistory(String meetingName) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('meetings').add({
        'meetingName': meetingName,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateProfile(Profile profile) async {
    final completer = Completer<bool>();
    try {
      await _firestore.collection(USER_COLLECTION).doc(profile.uniqueId).set(
            profile.toMap(),
            SetOptions(merge: false),
          );
      completer.complete(true);
    } catch (e) {
      completer.complete(false);
    }
    return completer.future;
  }

  Future<List<Profile>> getAllProfile() {
    Completer<List<Profile>> completer = Completer<List<Profile>>();
    final List<Profile> profiles = [];
    _firestore.collection(USER_COLLECTION).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docChanges.forEach((element) {
        final doc = element.doc;
        if (doc.exists) {
          if (doc.data() is Map<String, dynamic>) {
            final profile = Profile.fromMap(doc.data() as Map<String, dynamic>);
            profiles.add(profile);
          }
        }
      });
      completer.complete(profiles);
    });
    return completer.future;
  }
}
