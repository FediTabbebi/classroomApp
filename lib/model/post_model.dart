import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/model/comment_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String id;
  CategoryModel category;
  String description;
  DocumentReference createdByRef;
  UserModel? createdBy;
  List<CommentModel>? comments;
  DateTime createdAt;
  DateTime updatedAt;

  PostModel({
    required this.id,
    required this.category,
    required this.description,
    required this.createdByRef,
    this.createdBy,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      category: CategoryModel.fromMap(map['category'] ?? {}),
      description: map['description'] ?? '',
      createdByRef: map['createdByRef'] as DocumentReference,
      comments: (map['comments'] as List<dynamic>?)?.map<CommentModel>((comment) => CommentModel.fromMap(comment)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      'description': description,
      'createdByRef': createdByRef,
      'createdAt': createdAt,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'updatedAt': updatedAt,
    };
  }
}
