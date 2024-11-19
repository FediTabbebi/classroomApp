import 'package:classroom_app/model/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String firstName;
  String lastName;
  String email;
  String password;
  String profilePicture;
  UserRole? role; // Change the type to UserRole
  DocumentReference roleRef;
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
    this.role,
    required this.createdAt,
    required this.roleRef,
    required this.updatedAt,
    required this.isDeleted,
  });

  // Updated factory constructor to parse the roleRef and handle the role separately
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      role: map['role'] != null ? UserRole.fromMap(map['role']) : null, // Check if role is available and parse it
      roleRef: map['roleRef'] as DocumentReference, // Cast roleRef to DocumentReference
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  // Updated toJson method to convert UserRole to map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profilePicture': profilePicture,
      'role': role?.toMap(), // Convert the role back to a map
      'roleRef': roleRef,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }
}
