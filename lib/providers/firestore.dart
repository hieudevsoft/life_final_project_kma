import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/domain/models/profile.dart';

class FirestoreProviders {
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
}
