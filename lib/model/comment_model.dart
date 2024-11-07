import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;

  String description;
  DocumentReference commentedByRef;
  UserModel? commentedBy;
  bool isSeen;
  DateTime createdAt;
  DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.description,
    required this.commentedByRef,
    this.commentedBy,
    required this.isSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      commentedByRef: map['commentedByRef'] as DocumentReference,
      isSeen: map['isSeen'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isSeen': isSeen,
      'createdAt': createdAt,
      'commentedByRef': commentedByRef,
      'updatedAt': updatedAt,
    };
  }
}
