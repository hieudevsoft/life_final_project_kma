// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String? name;
  final String? email;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final String? phoneNumber;
  final String? photoUrl;
  final String? providerId;
  final String? userId;
  final String? uniqueId;
  final String? locale;

  const Profile({
    this.name,
    this.email,
    this.isVerified,
    this.createdAt,
    this.lastSignInTime,
    this.phoneNumber,
    this.photoUrl,
    this.providerId,
    this.userId,
    this.uniqueId,
    this.locale,
  });

  @override
  List<Object> get props {
    return [
      name ?? '',
      email ?? '',
      isVerified ?? '',
      createdAt ?? '',
      lastSignInTime ?? '',
      phoneNumber ?? '',
      photoUrl ?? '',
      providerId ?? '',
      userId ?? '',
      uniqueId ?? '',
      locale ?? '',
    ];
  }

  Profile copyWith({
    String? name,
    String? email,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    String? phoneNumber,
    String? photoUrl,
    String? providerId,
    String? userId,
    String? uniqueId,
    String? locale,
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      uniqueId: uniqueId ?? this.uniqueId,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'providerId': providerId,
      'userId': userId,
      'uniqueId': uniqueId,
      'locale': locale,
    };
  }

  factory Profile.fromMapFireStore(Map<String, dynamic> map) {
    return Profile(
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      isVerified: map['isVerified'] != null ? map['isVerified'] as bool : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastSignInTime: (map['lastSignInTime'] as Timestamp).toDate(),
      phoneNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      providerId: map['providerId'] != null ? map['providerId'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
      uniqueId: map['uniqueId'] != null ? map['uniqueId'] as String : null,
      locale: map['locale'] != null ? map['locale'] as String : null,
    );
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      isVerified: map['isVerified'] != null ? map['isVerified'] as bool : null,
      createdAt: DateTime.tryParse(map['createdAt']),
      lastSignInTime: DateTime.tryParse(map['lastSignInTime']),
      phoneNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      providerId: map['providerId'] != null ? map['providerId'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
      uniqueId: map['uniqueId'] != null ? map['uniqueId'] as String : null,
      locale: map['locale'] != null ? map['locale'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) => Profile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  bool get avatarUrlIsLink => photoUrl?.contains('http') ?? false;
}
