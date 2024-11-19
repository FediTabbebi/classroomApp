import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

class StorageService {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<String> uploadImage(Uint8List imageData, String imageName, String imagePath) async {
    final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
    );

    final String fileName = imageName;
    final ref = firebase_storage.FirebaseStorage.instance.ref().child("$imagePath/$fileName");

    await ref.putData(imageData, metadata);
    final String downloadURL = await ref.getDownloadURL();
    if (kDebugMode) {
      print('File uploaded to Firestore. Download URL: $downloadURL');
    }
    return downloadURL;
  }

  // Uploads a file to Firebase Storage
  Future<String?> uploadFile(String classroomId, PlatformFile file) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('Classroom files/$classroomId/${file.name}');

      // Handle web vs mobile
      firebase_storage.UploadTask uploadTask;
      if (kIsWeb) {
        // On web, use the `bytes` property
        uploadTask = storageRef.putData(
          file.bytes!,
          firebase_storage.SettableMetadata(contentType: lookupMimeType(file.name)),
        );
      } else {
        // On mobile/desktop, use the `path` property
        final filePath = file.path!;
        uploadTask = storageRef.putFile(
          io.File(filePath),
          firebase_storage.SettableMetadata(contentType: lookupMimeType(file.name)),
        );
      }

      // Wait for the upload to complete
      firebase_storage.TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("File uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error during file upload: $e");
      return null;
    }
  }

  // Uploads a file to Firebase Storage
  // Future<String> uploadFileFromBytes(Uint8List fileBytes, String fileName, String folderPath) async {
  //   try {
  //     // Create a reference in Firebase Storage
  //     firebase_storage.Reference ref = storage.ref().child('$folderPath/$fileName');

  //     // Upload the file data
  //     firebase_storage.UploadTask uploadTask = ref.putData(fileBytes);
  //     firebase_storage.TaskSnapshot snapshot = await uploadTask;

  //     // Retrieve the download URL
  //     String fileUrl = await snapshot.ref.getDownloadURL();
  //     return fileUrl;
  //   } catch (e) {
  //     throw Exception("File upload failed: $e");
  //   }
  // }

  Future<String?> uploadFileWithProgress(
    String classroomId,
    PlatformFile file,
    Function(double progress) onProgress,
  ) async {
    try {
      // Reference to the file location in Firebase Storage
      final ref = firebase_storage.FirebaseStorage.instance.ref().child('Classroom files/$classroomId/${file.name}');

      // Check if the file is picked for web or mobile
      firebase_storage.UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(
          file.bytes!,
          firebase_storage.SettableMetadata(contentType: file.extension ?? "application/octet-stream"),
        );
      } else {
        final filePath = io.File(file.path!);
        uploadTask = ref.putFile(filePath);
      }

      // Track upload progress
      uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        onProgress(progress);
        print(progress);
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error during file upload: $e");
      return null;
    }
  }
}
