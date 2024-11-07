import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel userFromJson(String str) => UserModel.fromMap(json.decode(str));

String userToJson(UserModel data) => json.encode(data.toJson());
final userRef = FirebaseFirestore.instance.collection('users').withConverter<UserModel>(
      fromFirestore: (snapshot, _) => UserModel.fromMap(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

class UserModel {
  String userId;
  String firstName;
  String lastName;
  String email;
  String password;
  String profilePicture;
  String role;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.profilePicture,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      role: map['role'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profilePicture': profilePicture,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }
}
