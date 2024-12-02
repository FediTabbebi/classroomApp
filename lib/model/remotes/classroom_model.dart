import 'package:classroom_app/model/files_folder_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/model/remotes/message_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomModel {
  String id;
  String label;
  String colorHex;
  DocumentReference createdByRef;
  UserModel? createdBy;
  List<DocumentReference>? invitedUsersRef;
  List<UserModel>? invitedUsers;
  List<MessageModel>? messages;
  DateTime createdAt;
  DateTime updatedAt;

  // Files and Folders
  List<FileModel>? files;
  List<FolderModel>? folders;
  List<ItemModel>? items; // Unified list for both files and folders

  ClassroomModel({
    required this.id,
    required this.label,
    required this.colorHex,
    required this.createdByRef,
    this.createdBy,
    this.invitedUsersRef,
    this.invitedUsers,
    this.messages,
    this.files,
    this.folders,
    this.items,
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
      messages: (map['messages'] as List<dynamic>?)?.map((comment) => MessageModel.fromMap(comment)).toList(),
      files: (map['files'] as List<dynamic>?)?.map((file) => FileModel.fromMap(file)).toList(),
      folders: (map['folders'] as List<dynamic>?)?.map((folder) => FolderModel.fromMap(folder)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    )..populateItems();
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
      'messages': messages?.map((comment) => comment.toJson()).toList(),
      'files': files?.map((file) => file.toJson()).toList(),
      'folders': folders?.map((folder) => folder.toJson()).toList(),
    };
  }

  void populateItems() {
    // Create a unified list of files and folders with their types
    List<ItemModel> combinedItems = [
      if (files != null) ...files!.map((file) => ItemModel(type: "file", file: file, createdAt: file.uploadedAt)),
      if (folders != null) ...folders!.map((folder) => ItemModel(type: "folder", folder: folder, createdAt: folder.createdAt)),
    ];

    // Sort the combined list by createdAt in descending order
    combinedItems.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Assign the sorted list to the items property
    items = combinedItems;
  }
}
