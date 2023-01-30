import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/exceptions/cancel_sign_in.dart';
import 'package:uvid/exceptions/google_sign_in.dart';

class AuthProviders {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future<bool> signInWithGoogleSuccessfully() async {
    final Completer<bool> completer = Completer();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? authencation = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authencation?.idToken,
        accessToken: authencation?.accessToken,
      );
      UserCredential? userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          final userProfile = Profile(
            name: user.displayName,
            email: user.email,
            isVerified: user.emailVerified,
            createdAt: user.metadata.creationTime,
            lastSignInTime: user.metadata.lastSignInTime,
            phoneNumber: user.phoneNumber,
            photoUrl: user.photoURL,
            providerId: user.providerData.first.providerId,
            userId: user.providerData.first.uid,
            uniqueId: user.uid,
            locale: userCredential.additionalUserInfo?.profile?['locale'] ?? 'Unknown',
          );
          await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).set(
                userProfile.toMap(),
                SetOptions(merge: false),
              );
          completer.complete(true);
        }
      } else {
        throw GoogleSignInException(msg: 'User is null');
      }
    } catch (e) {
      print(e);
      if (e.toString().contains('At least one of ID token and access token is required')) {
        throw CancelSignInException(msg: e);
      }
      throw GoogleSignInException(msg: e);
    }
    return completer.future;
  }
}
