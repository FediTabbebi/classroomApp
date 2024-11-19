import 'dart:io';
import 'dart:isolate';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/file_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/service/storage_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_dialog.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

class ClassroomProvider with ChangeNotifier {
  ClassroomService service = locator<ClassroomService>();
  StorageService storage = locator<StorageService>();
  ThemeProvider themeProvider = locator<ThemeProvider>();
  UserModel? currentUser;

  String fliterQuery = "";

  final TextEditingController classroomLabelController = TextEditingController();
  final GlobalKey<FormState> classRoomFormKey = GlobalKey<FormState>();
  bool isSelectFromAllCategories = false;
  bool? updating;
  Color? selectedColor;
  final classRoomMultiKey = GlobalKey<DropdownSearchState<String>>();

  List<UserModel> selectedUsers = [];
  bool? usersPopupBuilderSelection = false;
  final usersPopupBuilderKey = GlobalKey<DropdownSearchState<String>>();

  final usersKey = GlobalKey<DropdownSearchState<UserModel>>();
  int currentIndex = 1;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void updatePageIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void handleCheckBoxState({bool updateState = true, required GlobalKey<DropdownSearchState<String>> popupBuilderKey, required bool? popupBuilderSelection}) {
    var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) notifyListeners();
  }

  Future<void> addClassroom(BuildContext context, ClassroomModel classroom) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Adding new classroom",
            content: "processing ...",
          );
        });
    await service.addClassroom(classroom).then((value) async {
      Navigator.of(dialogContext!).pop();
      Navigator.of(context).pop();
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<void> deleteClassroom(BuildContext context, String classroomId) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Deleting classroom",
            content: "processing ...",
          );
        });
    await service.deleteclassroom(classroomId).then((value) async {
      Navigator.of(dialogContext!).pop();
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<void> showingDialog(
    BuildContext context,
    String title,
    String contents,
  ) async {
    await showAnimatedDialog<void>(
        context: context,
        barrierDismissible: true,
        duration: const Duration(milliseconds: 150),
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: title,
            dialogContent: contents,
            onConfirm: () {
              //  Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        });
  }

  Future<void> updateClassroom(BuildContext context, ClassroomModel classroom) async {
    BuildContext? dialogContext;
    if (detectClassroomChange(classroom)) {
      print(colorToHex(selectedColor!) == classroom.colorHex);
      print("selected color hex ${colorToHex(selectedColor!)}");
      print("original color hex ${classroom.colorHex}");
      showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
    } else {
      final List<String> selectedUsersIds = [];
      List<DocumentReference> invitedUsersRef = [];
      for (var e in selectedUsers) {
        selectedUsersIds.add(e.userId);
      }

      if (selectedUsersIds.isNotEmpty) {
        invitedUsersRef = selectedUsersIds.map((userId) {
          return FirebaseFirestore.instance.doc('users/$userId');
        }).toList();
      }

      final updatedClassroom = ClassroomModel(
        id: classroom.id,
        invitedUsersRef: invitedUsersRef,
        label: classroomLabelController.text,
        colorHex: colorToHex(selectedColor!),
        comments: classroom.comments,
        createdByRef: classroom.createdByRef,
        files: classroom.files,
        createdAt: classroom.createdAt,
        updatedAt: DateTime.now(),
      );
      showDialog<void>(
          //  barrierColor: Colors.transparent,
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cxt) {
            dialogContext = cxt;
            return const LoadingProgressDialog(
              title: "Updating classroom",
              content: "Processing...",
            );
          });
      await service.updateClassroom(updatedClassroom).then((value) async {
        Navigator.of(dialogContext!).pop();
        Navigator.of(context).pop();
      }).onError((error, stackTrace) {
        Navigator.of(dialogContext!).pop();
        showingDialog(context, "errors", '$error');
      });
    }
  }

  Future<void> pickAndUploadFileAndUpdateClassroom(
    BuildContext context,
    ClassroomModel classroom,
    UserModel currentUser,
  ) async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        print("File picking cancelled.");
        return;
      } else {
        BuildContext? dialogContext;
        PlatformFile pickedFile = result.files.first;
        print("Picked file: ${pickedFile.name}");

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) {
            dialogContext = ctx;
            return const LoadingProgressDialog(title: 'Uploading File...', content: "Processing");
          },
        );
        // Upload the file to Firebase Storage
        String? fileUrl = await storage.uploadFile(classroom.id, pickedFile);
        if (fileUrl == null) {
          showingDialog(context, "File Upload Failed", "Failed to upload the file. Please try again.");
          return;
        }

        // Create a FileModel for the uploaded file
        FileModel newFile = FileModel(
            fileId: const Uuid().v1(),
            fileUrl: fileUrl,
            fileType: pickedFile.extension ?? "unknown",
            senderRef: FirebaseFirestore.instance.doc('users/${currentUser.userId}'),
            fileName: pickedFile.name,
            uploadedAt: DateTime.now(),
            sender: currentUser);

        // Update the ClassroomModel with the new file
        List<FileModel> updatedFiles = classroom.files ?? [];
        updatedFiles.add(newFile);

        final updatedClassroom = ClassroomModel(
          id: classroom.id,
          invitedUsersRef: classroom.invitedUsersRef,
          label: classroom.label,
          colorHex: classroom.colorHex,
          comments: classroom.comments,
          createdByRef: classroom.createdByRef,
          createdAt: classroom.createdAt,
          updatedAt: DateTime.now(),
          files: updatedFiles, // Add updated files list
        );

        // Show loading dialog

        // Update the classroom in Firestore
        await service.updateClassroom(updatedClassroom).then((value) async {
          Navigator.of(dialogContext!).pop();
          //  Navigator.of(context).pop();
          print("Classroom updated successfully.");
        }).onError((error, stackTrace) {
          Navigator.of(dialogContext!).pop();
          showingDialog(context, "Error", '$error');
        });
      }
    } catch (e) {
      print("Error during file picking and upload: $e");
      showingDialog(context, "Error", "An error occurred: $e");
    }
  }

  Future<void> pickAndUploadFileWithNotification(
    BuildContext context,
    ClassroomModel classroom,
    UserModel currentUser,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        print("File picking cancelled.");
        return;
      }

      PlatformFile pickedFile = result.files.first;
      File file = File(pickedFile.path!);

      // Firebase storage reference
      final storageRef = FirebaseStorage.instance.ref().child('classrooms/${classroom.id}/${pickedFile.name}');
      final uploadTask = storageRef.putFile(file);

      // Display upload notification
      const int notificationId = 1;
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        "Uploading File",
        "0% completed",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'upload_channel',
            'File Uploads',
            channelDescription: 'Track file uploads',
            importance: Importance.high,
            priority: Priority.high,
            showProgress: true,
            maxProgress: 100,
            indeterminate: false,
          ),
        ),
      );

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

        // Update progress notification
        await flutterLocalNotificationsPlugin.show(
          notificationId,
          "Uploading File",
          "${progress.toStringAsFixed(0)}% completed",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'upload_channel',
              'File Uploads',
              channelDescription: 'Track file uploads',
              importance: Importance.high,
              priority: Priority.high,
              showProgress: true,
              maxProgress: 100,
              indeterminate: false,
            ),
          ),
        );
      });

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Get file URL
        String fileUrl = await storageRef.getDownloadURL();

        // Create FileModel
        FileModel newFile = FileModel(
          fileId: const Uuid().v1(),
          fileUrl: fileUrl,
          fileType: pickedFile.extension ?? "unknown",
          senderRef: FirebaseFirestore.instance.doc('users/${currentUser.userId}'),
          fileName: pickedFile.name,
          uploadedAt: DateTime.now(),
          sender: currentUser,
        );

        // Update classroom files
        List<FileModel> updatedFiles = classroom.files ?? [];
        updatedFiles.add(newFile);

        final updatedClassroom = ClassroomModel(
          id: classroom.id,
          invitedUsersRef: classroom.invitedUsersRef,
          label: classroom.label,
          colorHex: classroom.colorHex,
          comments: classroom.comments,
          createdByRef: classroom.createdByRef,
          createdAt: classroom.createdAt,
          updatedAt: DateTime.now(),
          files: updatedFiles,
        );

        // Update Firestore
        await service.updateClassroom(updatedClassroom);

        // Show success notification
        await flutterLocalNotificationsPlugin.show(
          notificationId,
          "Upload Complete",
          "File uploaded successfully.",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'upload_channel',
              'File Uploads',
              channelDescription: 'Track file uploads',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );

        print("File uploaded successfully: $fileUrl");
      });
    } catch (e) {
      print("Error during file upload: $e");
      showingDialog(context, "Error", "An error occurred: $e");
    }
  }

  Future<void> deleteFileFromClassroom(BuildContext context, ClassroomModel classroom, String fileId) async {
    BuildContext? dialogContext;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        dialogContext = ctx;
        return const LoadingProgressDialog(title: 'Uploading File...', content: "Processing");
      },
    );
    classroom.files!.removeWhere((e) => e.fileId == fileId);
    await service.updateClassroom(classroom).then((value) async {
      Navigator.of(dialogContext!).pop();
      //  Navigator.of(context).pop();
      print("Classroom updated successfully.");
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      showingDialog(context, "Error", '$error');
    });
  }

  // Future<void> downloadFileFromFirebase(String firebasePath, String fileName) async {
  //   try {
  //     // Request storage permission
  //     if (!await requestStoragePermission()) {
  //       print('Storage permission is required to save the file.');
  //       return;
  //     }

  //     // Get reference to Firebase Storage file
  //     final ref = FirebaseStorage.instance.ref(firebasePath);

  //     // Temporary directory
  //     final tempDir = await getTemporaryDirectory();
  //     final tempFile = File('${tempDir.path}/$fileName');

  //     // Download file to temporary location
  //     await ref.writeToFile(tempFile);
  //     print('File downloaded to temporary directory: ${tempFile.path}');

  //     // Move file to Downloads directory
  //     final downloadsDir = Directory('/storage/emulated/0/Download');
  //     if (!downloadsDir.existsSync()) {
  //       print('Downloads directory does not exist.');
  //       return;
  //     }

  //     final finalFile = File('${downloadsDir.path}/$fileName');
  //     await tempFile.copy(finalFile.path);

  //     print('File saved to Downloads directory: ${finalFile.path}');
  //   } catch (e) {
  //     print('Error downloading file: $e');
  //   }
  // }

  Future<bool> requestStoragePermission() async {
    // final status = await Permission.storage.request();
    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print('Storage permission granted.');
      return true;
    } else if (status.isDenied) {
      print('Storage permission denied.');
      return false;
    } else if (status.isPermanentlyDenied) {
      print('Storage permission permanently denied. Redirecting to app settings...');
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<void> downloadFileFromFirebaseWeb(String firebasePath) async {
    try {
      final ref = FirebaseStorage.instance.ref(firebasePath);
      final url = await ref.getDownloadURL();

      final anchor = html.AnchorElement(href: url)
        ..target = '_self'
        ..download = firebasePath.split('/').last; // Extract file name from path
      anchor.click();
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> downloadFileWithIsolate(String filePath, String downloadPath) async {
    final receivePort = ReceivePort();

    try {
      await Isolate.spawn(
        _downloadFileIsolate,
        {
          'filePath': filePath,
          'downloadPath': downloadPath,
          'sendPort': receivePort.sendPort,
        },
      );

      final result = await receivePort.first;
      print('Received result: $result'); // Debugging line

      if (result is String) {
        print('Error: $result'); // Handle error if isolate sends an error message
      } else if (result is File) {
        print('File downloaded successfully: ${result.path}');
      }
    } catch (e) {
      print('Error during isolate execution: $e');
    }
  }

// Isolate function that handles the file download
  void _downloadFileIsolate(Map<String, dynamic> params) async {
    final String filePath = params['filePath'];
    final String downloadPath = params['downloadPath'];
    final SendPort sendPort = params['sendPort'];

    print('Isolate started for $filePath'); // Debugging line

    try {
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      final File file = File(downloadPath);

      // Debugging the download attempt
      print('Downloading file from Firebase...');
      await storageRef.writeToFile(file);

      print('File downloaded successfully!'); // Debugging line

      // Send the file object back to the main thread
      sendPort.send(file);
    } catch (e) {
      print('Error: $e');
      sendPort.send('Error: $e');
    }
  }

  // Future<void> requestStoragePermission() async {
  //   PermissionStatus status = await Permission.storage.status;

  //   if (!status.isGranted) {
  //     status = await Permission.storage.request();

  //     if (status.isGranted) {
  //       print('Storage permission granted');
  //     } else if (status.isDenied) {
  //       print('Storage permission denied');
  //     } else if (status.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //   } else {
  //     print('Storage permission already granted');
  //   }
  // }

  bool detectClassroomChange(ClassroomModel classroom) {
    final List<String> origianlSelectedUsersId = [];
    final List<String> selectedUsersIds = [];
    if (classroom.invitedUsers != null) {
      for (var e in classroom.invitedUsers!) {
        origianlSelectedUsersId.add(e.userId);
      }
    }

    for (var e in selectedUsers) {
      selectedUsersIds.add(e.userId);
    }

    return classroom.label == classroomLabelController.text &&
        const SetEquality().equals(origianlSelectedUsersId.toSet(), selectedUsersIds.toSet()) &&
        (colorToHex(selectedColor!) == classroom.colorHex);
  }

  void updateCategorySelection() {
    isSelectFromAllCategories = !isSelectFromAllCategories;
    notifyListeners();
  }

  void selectUsers(List<UserModel> users) {
    selectedUsers = users;
    notifyListeners();
  }

  void clearControllers(BuildContext context) {
    classroomLabelController.clear();
    selectedUsers.clear();
    selectedColor = Theme.of(context).colorScheme.primary;
    notifyListeners();
  }

  void addNewUsers(
    List<UserModel> newValue,
  ) {
    selectedUsers = [];

    selectedUsers.addAll(newValue);

    notifyListeners();
  }

  void deleteUser(int index) {
    selectedUsers.removeAt(index);
    notifyListeners();
  }

  void initControllers(ClassroomModel classroom) {
    classroomLabelController.text = classroom.label;
    selectedUsers = classroom.invitedUsers ?? [];
    selectedColor = hexToColor(classroom.colorHex);
  }

  void updateSelectedColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  Future<void> downloadFileFromFirebase(String firebasePath, String localFileName) async {
    const notificationId = 0;

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

      // Start file download
      ref.writeToFile(tempFile).snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.running) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            await _showNotification(
              notificationId,
              'Downloading...',
              'Downloading $localFileName (${progress.toStringAsFixed(0)}%)',
              progress: progress.toInt(),
            );
          } else if (snapshot.state == TaskState.success) {
            // Handle successful download
            await _saveFileToDownloads(tempFile, localFileName);
            await _showNotification(
              notificationId,
              'Download Complete',
              '$localFileName saved to Downloads.',
            );
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
      // Check if we can use the scoped Downloads directory
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
