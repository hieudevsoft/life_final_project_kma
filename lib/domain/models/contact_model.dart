// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final String? keyId;
  final String? userId;
  final String? name;
  final String? description;
  final String? urlLinkImage;
  final int friendStatus;

  ContactModel(
    this.keyId,
    this.userId,
    this.name,
    this.description,
    this.urlLinkImage,
    this.friendStatus,
  );

  ContactModel copyWith({
    String? keyId,
    String? userId,
    String? name,
    String? description,
    String? urlLinkImage,
    int? friendStatus,
  }) {
    return ContactModel(
      keyId ?? this.keyId,
      userId ?? this.userId,
      name ?? this.name,
      description ?? this.description,
      urlLinkImage ?? this.urlLinkImage,
      friendStatus ?? this.friendStatus,
    );
  }

  @override
  List<Object> get props {
    return [
      keyId ?? '',
      userId ?? '',
      name ?? '',
      description ?? '',
      urlLinkImage ?? '',
      friendStatus,
    ];
  }

  @override
  bool get stringify => true;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keyId': keyId,
      'userId': userId,
      'name': name,
      'description': description,
      'urlLinkImage': urlLinkImage,
      'friendStatus': friendStatus,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      map['keyId'] != null ? map['keyId'] as String : null,
      map['userId'] != null ? map['userId'] as String : null,
      map['name'] != null ? map['name'] as String : null,
      map['description'] != null ? map['description'] as String : null,
      map['urlLinkImage'] != null ? map['urlLinkImage'] as String : null,
      map['friendStatus'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) => ContactModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
