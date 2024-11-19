import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  String fileId;
  String fileUrl; // Link to the file
  DocumentReference senderRef; // Reference to the sender
  UserModel? sender; // UserModel of the sender (populated later)
  String fileName; // Name of the file
  String fileType; // Type of file (e.g., PDF, image, etc.)
  DateTime uploadedAt; // Timestamp of upload

  FileModel({
    required this.fileId,
    required this.fileUrl,
    required this.senderRef,
    this.sender,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
  });

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileId: map['fileId'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      senderRef: FirebaseFirestore.instance.doc(map['senderRef'] ?? ''), // Convert string to DocumentReference
      fileName: map['fileName'] ?? '',
      fileType: map['fileType'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileUrl': fileUrl,
      'senderRef': senderRef.path, // Store reference as path (String)
      'fileName': fileName,
      'fileType': fileType,
      'uploadedAt': uploadedAt,
    };
  }
}
