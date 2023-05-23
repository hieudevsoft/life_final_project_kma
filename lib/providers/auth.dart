import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/exceptions/cancel_sign_in.dart';
import 'package:uvid/exceptions/google_sign_in.dart';
import 'package:uvid/exceptions/sign_out.dart';
import 'package:uvid/utils/notifications.dart';

class AuthProviders {
  AuthProviders._();
  static get _instance => AuthProviders._();
  factory AuthProviders() {
    return _instance;
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(signInOption: SignInOption.standard);
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();
  User? get currentUserFirebase => _firebaseAuth.currentUser;

  Future<bool> signInWithGoogle() async {
    final Completer<bool> completer = Completer();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? authencation = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authencation?.idToken,
        accessToken: authencation?.accessToken,
      );
      UserCredential? userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        Profile userProfile = Profile(
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
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).set(
                userProfile.toMap(),
                SetOptions(merge: false),
              );
        } else {
          final docSnapshot = await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).get();
          if (docSnapshot.exists) {
            if (docSnapshot.data() != null) {
              userProfile = Profile.fromMap(docSnapshot.data()!).copyWith(lastSignInTime: userProfile.lastSignInTime);
            }
          }
        }
        LocalStorage().setProfile(userProfile);
        LocalStorage().setAccessToken(userCredential.credential?.accessToken);
        completer.complete(true);
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

  Future<bool> signInWithFacebook() async {
    final Completer<bool> completer = Completer();
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken != null) {
          final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          User? user = userCredential.user;
          if (user != null) {
            Profile userProfile = Profile(
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
            if (userCredential.additionalUserInfo!.isNewUser) {
              await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).set(
                    userProfile.toMap(),
                    SetOptions(merge: false),
                  );
            } else {
              final docSnapshot = await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).get();
              if (docSnapshot.exists) {
                if (docSnapshot.data() != null) {
                  userProfile = Profile.fromMap(docSnapshot.data()!).copyWith(lastSignInTime: userProfile.lastSignInTime);
                }
              }
            }
            LocalStorage().setProfile(userProfile);
            LocalStorage().setAccessToken(userCredential.credential?.accessToken);
            completer.complete(true);
          }
        }
      } else {
        print('Login facebook failure: ${result.status}, ${result.message}');
        completer.complete(false);
      }
    } catch (e) {
      rethrow;
    }
    return completer.future;
  }

  void requestOTP(
    String phoneNumber,
    Function(String) onCodeSent, {
    Function(String)? onAutoRetrievalTimeout = null,
    Function(Object)? onException = null,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('verificationCompleted $credential');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (onException != null) {
            onException(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (onAutoRetrievalTimeout != null) {
            onAutoRetrievalTimeout(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (onException != null) {
        onException(e);
      }
    }
  }

  Future<bool> verifyOTP(
    String verifyId,
    String smsCode, {
    bool isJustVerify = false,
    Function(Object)? onException = null,
    Function(String?)? onPhoneCallback = null,
  }) async {
    final Completer<bool> completer = Completer();
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verifyId, smsCode: smsCode);
      UserCredential? userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null && !isJustVerify) {
        Profile userProfile = Profile(
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
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).set(
                userProfile.toMap(),
                SetOptions(merge: false),
              );
        } else {
          final docSnapshot = await _firebaseFirestore.collection(USER_COLLECTION).doc(user.uid).get();
          if (docSnapshot.exists) {
            if (docSnapshot.data() != null) {
              userProfile = Profile.fromMap(docSnapshot.data()!).copyWith(lastSignInTime: userProfile.lastSignInTime);
            }
          }
        }
        LocalStorage().setProfile(userProfile);
        LocalStorage().setAccessToken(userCredential.credential?.accessToken);
        completer.complete(true);
      } else if (user != null && isJustVerify) {
        if (onPhoneCallback != null) {
          onPhoneCallback(user.phoneNumber);
          completer.complete(true);
        }
      } else {
        if (onException != null) {
          onException(FirebaseAuthException);
        }
        completer.complete(false);
      }
    } catch (e) {
      if (onException != null) {
        onException(e);
      }
      completer.complete(false);
    }
    return completer.future;
  }

  void signInWithLocalAuth({
    required Function onSuccessLocalAuth,
    required Function onHardwareNotSupportBiometrics,
    required Function onDeviceSupportBiometrics,
  }) async {
    final bool canAuthenticateWithBiometrics = await _localAuthentication.canCheckBiometrics;
    if (!canAuthenticateWithBiometrics) {
      onHardwareNotSupportBiometrics();
      return;
    }
    final isDeviceSupported = await _localAuthentication.isDeviceSupported();
    if (!isDeviceSupported) {
      onDeviceSupportBiometrics();
      return;
    }
    final biometricsAvailable = await _localAuthentication.getAvailableBiometrics();
    if (biometricsAvailable.isNotEmpty) {
      try {
        final bool didAuthenticate = await _localAuthentication.authenticate(
          localizedReason: 'Please authenticate to login',
          options: const AuthenticationOptions(sensitiveTransaction: true),
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Oops! Biometric authentication required!',
              cancelButton: 'No thanks',
            ),
            IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ],
        );
        if (didAuthenticate) {
          onSuccessLocalAuth();
        }
      } on PlatformException catch (e) {
        print(e);
      } on Exception catch (e) {
        print(e);
      }
    } else {
      onDeviceSupportBiometrics();
    }
  }

  void signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await FacebookAuth.instance.logOut();
      LocalStorage().setProfile(null);
      LocalStorage().setAccessToken(null);
      NotificationManager().cancelAllScheduledNotification();
    } catch (e) {
      throw SignOutException(msg: e);
    }
  }
}
