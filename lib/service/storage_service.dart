import 'dart:io' as io;

import 'package:classroom_app/provider/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

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

  Future<String?> uploadFileWithProgressSnackbar({
    required BuildContext context,
    required String classroomId,
    required PlatformFile file,
  }) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('Classroom files/$classroomId/${file.name}');

      // Handle web vs mobile
      firebase_storage.UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = storageRef.putData(
          file.bytes!,
          firebase_storage.SettableMetadata(contentType: lookupMimeType(file.name)),
        );
      } else {
        final filePath = file.path!;
        uploadTask = storageRef.putFile(
          io.File(filePath),
          firebase_storage.SettableMetadata(contentType: lookupMimeType(file.name)),
        );
      }

      // Create a SnackBar for progress updates
      double uploadProgress = 0.0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 3,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Listen to upload progress
              uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
                uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                print(uploadProgress);

                // Trigger a rebuild in the SnackBar
                setState(() {});
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploading: ${file.name}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium!.color!),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: uploadProgress / 100, backgroundColor: Theme.of(context).highlightColor.withOpacity(0.5), color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('${uploadProgress.toStringAsFixed(0)}% Complete',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                      )),
                ],
              );
            },
          ),
          backgroundColor: Theme.of(context).cardTheme.color,
          duration: const Duration(days: 1), // Will be manually closed later
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Wait for the upload to complete
      firebase_storage.TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("File uploaded successfully: $downloadUrl");

      // Replace the progress SnackBar with a completion message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Upload complete! Your file has been uploaded successfully", style: TextStyle(color: Colors.white)),
          backgroundColor: context.read<ThemeProvider>().isDarkMode ? const Color(0xff154406) : const Color(0xff007958),
          duration: const Duration(seconds: 2),
        ),
      );

      return downloadUrl;
    } catch (e) {
      print("Error during file upload: $e");

      // Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during upload: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      return null;
    }
  }
}
