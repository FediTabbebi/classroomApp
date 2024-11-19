import 'package:classroom_app/model/comment_model.dart';
import 'package:classroom_app/model/file_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomModel {
  String id;
  String label;
  String colorHex;
  DocumentReference createdByRef;
  UserModel? createdBy;
  List<DocumentReference>? invitedUsersRef;
  List<UserModel>? invitedUsers;
  List<CommentModel>? comments;
  DateTime createdAt;
  DateTime updatedAt;

  // New attribute for handling files
  List<FileModel>? files;

  ClassroomModel({
    required this.id,
    required this.label,
    required this.colorHex,
    required this.createdByRef,
    this.createdBy,
    this.invitedUsersRef,
    this.invitedUsers,
    this.comments,
    this.files,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassroomModel.fromMap(Map<String, dynamic> map) {
    return ClassroomModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      colorHex: map['colorHex'] ?? '',
      createdByRef: map['createdByRef'] as DocumentReference,
      invitedUsersRef: (map['invitedUsersRef'] as List<dynamic>?)?.map((item) {
        if (item is DocumentReference) {
          return item;
        } else if (item is String) {
          return FirebaseFirestore.instance.doc(item);
        } else {
          throw TypeError();
        }
      }).toList(),
      comments: (map['comments'] as List<dynamic>?)?.map((comment) => CommentModel.fromMap(comment)).toList(),
      files: (map['files'] as List<dynamic>?)?.map((file) => FileModel.fromMap(file)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'colorHex': colorHex,
      'createdByRef': createdByRef,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'invitedUsersRef': invitedUsersRef?.map((ref) => ref.path).toList(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'files': files?.map((file) => file.toJson()).toList(),
    };
  }
}
