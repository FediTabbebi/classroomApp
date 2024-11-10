import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

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
}
