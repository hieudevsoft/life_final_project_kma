// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:equatable/equatable.dart';

class FriendModel extends Equatable {
  final String userId;
  final String name;
  final String? image;
  final String description;
  final int time;
  const FriendModel({
    required this.userId,
    required this.name,
    this.image,
    required this.description,
    required this.time,
  });

  FriendModel copyWith({
    String? userId,
    String? name,
    String? image,
    String? description,
    int? time,
  }) {
    return FriendModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'image': image,
      'description': description,
      'time': time,
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      userId: map['userId'] as String,
      name: map['name'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      description: map['description'] as String,
      time: map['time'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FriendModel.fromJson(String source) => FriendModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      userId,
      name,
      image ?? '',
      description,
      time,
    ];
  }
}
