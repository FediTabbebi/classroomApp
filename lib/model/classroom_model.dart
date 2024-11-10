import 'package:classroom_app/model/comment_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomModel {
  String id;
  String label;
  String colorHex; // Store the color as a hex string
  DocumentReference createdByRef;
  UserModel? createdBy;
  List<DocumentReference>? invitedUsersRef;
  List<UserModel>? invitedUsers;
  List<CommentModel>? comments;
  DateTime createdAt;
  DateTime updatedAt;

  ClassroomModel({
    required this.id,
    required this.label,
    required this.colorHex, // Added as required to match your model usage
    required this.createdByRef,
    this.createdBy,
    this.invitedUsersRef,
    this.invitedUsers,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create ClassroomModel from a map
  factory ClassroomModel.fromMap(Map<String, dynamic> map) {
    return ClassroomModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      colorHex: map['colorHex'] ?? '',
      createdByRef: map['createdByRef'] as DocumentReference,
      invitedUsersRef: (map['invitedUsersRef'] as List<dynamic>?)?.map((item) {
        // Check if item is already a DocumentReference or a string path
        if (item is DocumentReference) {
          return item;
        } else if (item is String) {
          return FirebaseFirestore.instance.doc(item);
        } else {
          throw TypeError();
        }
      }).toList(),
      comments: (map['comments'] as List<dynamic>?)?.map((comment) => CommentModel.fromMap(comment)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert the model to JSON format for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'colorHex': colorHex,
      'createdByRef': createdByRef,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'invitedUsersRef': invitedUsersRef?.map((ref) => ref.path).toList(), // Convert to paths
      'comments': comments?.map((comment) => comment.toJson()).toList(),
    };
  }
}
