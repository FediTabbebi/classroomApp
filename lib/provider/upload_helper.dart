import 'dart:io';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/download_helper.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

ClassroomService service = locator<ClassroomService>();

class UploadHelper {
  Future<void> initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> pickAndUploadFileWithNotification({
    required BuildContext context,
    required ClassroomModel classroom,
    required UserModel currentUser,
    String? folderId,
  }) async {
    const int notificationId = 1;

    try {
      // Step 1: Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        return;
      }

      PlatformFile pickedFile = result.files.first;
      File file = File(pickedFile.path!);
      // Request Storage Permissions
      if (!(await _requestStoragePermission())) {
        await _showNotification(notificationId, 'Permission Denied', 'Notification permission is required', importance: Importance.high, priority: Priority.high);
        return;
      }
      // Step 2: Prepare Firebase storage reference
      final storageRef = FirebaseStorage.instance.ref().child('Classroom files/${classroom.id}/${pickedFile.name}');
      final uploadTask = storageRef.putFile(file);

      // Step 3: Show initial "Uploading..." notification
      await _showNotification(
        notificationId,
        "Uploading File",
        "0% completed",
        progress: 0,
        importance: Importance.high,
        priority: Priority.high,
      );

      // Step 4: Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

        // Update progress in notification
        await _showNotification(
          notificationId,
          "Uploading File",
          "${progress.toStringAsFixed(0)}% completed",
          progress: progress.toInt(),
          importance: Importance.low,
          priority: Priority.low,
        );
      });

      // Step 5: Handle upload completion
      await uploadTask.whenComplete(() async {
        // Get download URL
        String fileUrl = await storageRef.getDownloadURL();

        // Create new FileModel
        FileModel newFile = FileModel(
          fileId: const Uuid().v1(),
          fileUrl: fileUrl,
          fileType: pickedFile.extension ?? "unknown",
          senderRef: FirebaseFirestore.instance.doc('users/${currentUser.userId}'),
          fileName: pickedFile.name,
          uploadedAt: DateTime.now(),
          sender: currentUser,
        );
        if (folderId != null) {
          final updatedFolderIndex = classroom.folders!.indexWhere((e) => e.folderId == folderId);
          List<FileModel> updatedFiles = classroom.folders![updatedFolderIndex].files!;
          updatedFiles.add(newFile);
          classroom.folders![updatedFolderIndex].files = updatedFiles;

          final updatedClassroom = ClassroomModel(
            folders: classroom.folders,
            id: classroom.id,
            invitedUsersRef: classroom.invitedUsersRef,
            label: classroom.label,
            colorHex: classroom.colorHex,
            messages: classroom.messages,
            createdByRef: classroom.createdByRef,
            createdAt: classroom.createdAt,
            updatedAt: DateTime.now(),
            files: classroom.files,
          );

          await service.updateClassroom(updatedClassroom);

          // Show "Upload Complete" notification
          await _showNotification(
            notificationId,
            "Upload Complete",
            "File uploaded successfully.",
            importance: Importance.high,
            priority: Priority.high,
          );

          print("File uploaded successfully: $fileUrl");
        } else {
          // Update classroom's file list
          List<FileModel> updatedFiles = classroom.files ?? [];
          updatedFiles.add(newFile);

          final updatedClassroom = ClassroomModel(
            folders: classroom.folders,
            id: classroom.id,
            invitedUsersRef: classroom.invitedUsersRef,
            label: classroom.label,
            colorHex: classroom.colorHex,
            messages: classroom.messages,
            createdByRef: classroom.createdByRef,
            createdAt: classroom.createdAt,
            updatedAt: DateTime.now(),
            files: updatedFiles,
          );

          // Save updated classroom to Firestore
          await service.updateClassroom(updatedClassroom);

          // Show "Upload Complete" notification
          await _showNotification(
            notificationId,
            "Upload Complete",
            "File uploaded successfully.",
            importance: Importance.high,
            priority: Priority.high,
          );

          print("File uploaded successfully: $fileUrl");
        }
      });
    } catch (e) {
      print("Error during file upload: $e");
      showingDialog(context, "Error", "An error occurred: $e");
    }
  }

  // Helper function to show notifications
  Future<void> _showNotification(
    int notificationId,
    String title,
    String body, {
    int? progress,
    required Importance importance,
    required Priority priority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'upload_channel',
      'File Uploads',
      channelDescription: 'Notifications for file uploads',
      importance: importance,
      priority: priority,
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

  Future<void> showingDialog(BuildContext context, String title, String contents) async {
    await showAnimatedDialog<void>(
        context: context,
        barrierDismissible: true,
        duration: const Duration(milliseconds: 150),
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: title,
            dialogContent: contents,
            onConfirm: () {
              Navigator.pop(context);
            },
          );
        });
  }

  // Helper function to request storage permission
  Future<bool> _requestStoragePermission() async {
    // Request notification permission (Android 13+)
    if (Platform.isAndroid && await Permission.notification.isDenied) {
      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) return false;
    }

    return true;
  }
}
