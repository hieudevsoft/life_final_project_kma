// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uvid/domain/models/contact_model.dart';

class FriendModel extends Equatable {
  final String? keyId;
  final String userId;
  final String name;
  final String? image;
  final String description;
  final int time;
  const FriendModel({
    required this.keyId,
    required this.userId,
    required this.name,
    this.image,
    required this.description,
    required this.time,
  });

  FriendModel copyWith({
    String? keyId,
    String? userId,
    String? name,
    String? image,
    String? description,
    int? time,
  }) {
    return FriendModel(
      keyId: keyId ?? this.userId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keyId': keyId,
      'userId': userId,
      'name': name,
      'image': image,
      'description': description,
      'time': time,
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      keyId: map['keyId'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      description: map['description'] as String,
      time: map['time'] as int,
    );
  }

  ContactModel toContactModel() {
    return ContactModel(keyId ?? '', userId, name, description, image, 2);
  }

  String toJson() => json.encode(toMap());

  factory FriendModel.fromJson(String source) => FriendModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      keyId ?? '',
      userId,
      name,
      image ?? '',
      description,
      time,
    ];
  }
}
