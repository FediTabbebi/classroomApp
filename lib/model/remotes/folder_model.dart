import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_model.dart';

class FolderModel {
  String folderId;
  String colorHex;
  String folderName;
  DocumentReference createdByRef;
  UserModel? createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  List<FileModel>? files; // Added list of files

  FolderModel({
    required this.folderId,
    required this.colorHex,
    required this.folderName,
    required this.createdByRef,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.files, // Initialize files as nullable
  });

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      folderId: map['folderId'] ?? '',
      folderName: map['folderName'] ?? '',
      colorHex: map['colorHex'] ?? '',
      createdByRef: FirebaseFirestore.instance.doc(map['createdByRef'] ?? ''),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      files: (map['files'] as List<dynamic>?)?.map((file) {
        return FileModel.fromMap(file as Map<String, dynamic>);
      }).toList(), // Map files to FileModel
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'folderName': folderName,
      'createdByRef': createdByRef.path,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'colorHex': colorHex,
      'files': files?.map((file) => file.toJson()).toList(), // Convert files to JSON
    };
  }
}
