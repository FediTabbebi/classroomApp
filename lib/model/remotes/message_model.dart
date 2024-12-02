import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String id;
  String description;
  DocumentReference senderRef;
  UserModel? sender;
  DateTime createdAt;
  DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.description,
    required this.senderRef,
    this.sender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      senderRef: map['senderRef'] as DocumentReference,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'createdAt': createdAt,
      'senderRef': senderRef,
      'updatedAt': updatedAt,
    };
  }
}
