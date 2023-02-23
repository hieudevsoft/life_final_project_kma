// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final String? keyId;
  final String? userId;
  final String? name;
  final String? description;
  final String? urlLinkImage;

  ContactModel(
    this.keyId,
    this.userId,
    this.name,
    this.description,
    this.urlLinkImage,
  );

  @override
  bool? get stringify => true;

  ContactModel copyWith({
    String? keyId,
    String? userId,
    String? name,
    String? description,
    String? urlLinkImage,
  }) {
    return ContactModel(
      keyId ?? this.keyId,
      userId ?? this.userId,
      name ?? this.name,
      description ?? this.description,
      urlLinkImage ?? this.urlLinkImage,
    );
  }

  @override
  List<Object> get props => [keyId ?? '', userId ?? '', name ?? '', description ?? ''];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keyId': keyId,
      'userId': userId,
      'name': name,
      'description': description,
      'urlLinkImage': urlLinkImage,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      map['keyId'] as String,
      map['userId'] as String,
      map['name'] as String,
      map['description'] as String,
      map['urlLinkImage'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) => ContactModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
