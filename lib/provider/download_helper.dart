import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class FileDownloadHelper {
  Future<void> initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> downloadFileFromFirebase(String firebasePath, String localFileName) async {
    const notificationId = 0; // Unique ID for the download notification

    try {
      // Request Storage Permissions
      if (!(await _requestStoragePermission())) {
        await _showNotification(
          notificationId,
          'Permission Denied',
          'Storage permission is required to save files.',
        );
        return;
      }

      // Firebase reference
      final ref = FirebaseStorage.instance.ref(firebasePath);

      // Temporary file for download
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$localFileName');

      // Display "Downloading..." notification
      await _showNotification(
        notificationId,
        'Downloading...',
        'Downloading $localFileName (0%)',
        progress: 0,
      );

      // Start file download and listen for progress
      ref.writeToFile(tempFile).snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          switch (snapshot.state) {
            case TaskState.running:
              final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
              await _showNotification(
                notificationId,
                'Downloading...',
                'Downloading $localFileName (${progress.toStringAsFixed(0)}%)',
                progress: progress.toInt(),
              );
              break;

            case TaskState.success:
              // Handle successful download
              await _saveFileToDownloads(tempFile, localFileName);
              await _showNotification(
                notificationId,
                'Download Complete',
                '$localFileName saved to Downloads.',
              );
              break;

            case TaskState.error:
              // Handle download error
              await _showNotification(
                notificationId,
                'Download Failed',
                'Failed to download $localFileName.',
              );
              break;

            default:
              break;
          }
        },
        onError: (error) async {
          print('Download error: $error');
          await _showNotification(
            notificationId,
            'Download Failed',
            'An error occurred while downloading $localFileName.',
          );
        },
      );
    } catch (e) {
      print('Unexpected error: $e');
      await _showNotification(
        notificationId,
        'Error',
        'Failed to download $localFileName.',
      );
    }
  }

  // Helper function to save file to Downloads folder
  Future<void> _saveFileToDownloads(File tempFile, String fileName) async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (await downloadsDir.exists()) {
        final downloadedFile = File('${downloadsDir.path}/$fileName');
        await tempFile.copy(downloadedFile.path);
        print('File saved to: ${downloadedFile.path}');
      } else {
        throw Exception('Downloads directory not accessible.');
      }
    } catch (e) {
      print('Error saving file: $e');
      throw Exception('Failed to save file to Downloads.');
    }
  }

  // Helper function to request storage permission
  Future<bool> _requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  // Helper function to show notifications
  Future<void> _showNotification(
    int notificationId,
    String title,
    String body, {
    int? progress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'File Downloads',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: progress != null,
      maxProgress: 100,
      progress: progress ?? 0,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
