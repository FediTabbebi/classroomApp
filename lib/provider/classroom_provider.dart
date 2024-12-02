import 'dart:typed_data';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
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
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

class ClassroomProvider with ChangeNotifier {
  ClassroomService service = locator<ClassroomService>();
  StorageService storage = locator<StorageService>();
  ThemeProvider themeProvider = locator<ThemeProvider>();
  UserModel? currentUser;
  bool isInsideFolder = false;
  String fliterQuery = "";
  FolderModel? currentFolder;
  final TextEditingController classroomLabelController = TextEditingController();

  final TextEditingController classroomFolderController = TextEditingController();
  final GlobalKey<FormState> classRoomFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> createFolderFormKey = GlobalKey<FormState>();
  bool isSelectFromAllCategories = false;
  bool? updating;
  Color? selectedColor;
  Color? folderSelectedColor;
  final classRoomMultiKey = GlobalKey<DropdownSearchState<String>>();

  List<UserModel> selectedUsers = [];
  bool? usersPopupBuilderSelection = false;
  final usersPopupBuilderKey = GlobalKey<DropdownSearchState<String>>();

  final usersKey = GlobalKey<DropdownSearchState<UserModel>>();
  int currentIndex = 1;

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
      if (dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }).onError((error, stackTrace) {
      if (dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }
      if (context.mounted) {
        showingDialog(context, "errors", '$error');
      }
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

  Future<void> updateClassroom(BuildContext context, ClassroomModel classroom) async {
    BuildContext? dialogContext;
    if (detectClassroomChange(classroom)) {
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
        messages: classroom.messages,
        createdByRef: classroom.createdByRef,
        files: classroom.files,
        folders: classroom.folders,
        createdAt: classroom.createdAt,
        updatedAt: DateTime.now(),
      );
      showDialog<void>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cxt) {
            dialogContext = cxt;
            return const LoadingProgressDialog(title: "Updating classroom", content: "Processing...");
          });
      await service.updateClassroom(updatedClassroom).then((value) async {
        if (dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }).onError((error, stackTrace) {
        if (dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        if (context.mounted) {
          showingDialog(context, "errors", '$error');
        }
      });
    }
  }

  Future<void> addFolderToClassRoom(BuildContext context, ClassroomModel classroom) async {
    BuildContext? dialogContext;

    final updatedClassroom = ClassroomModel(
      id: classroom.id,
      invitedUsersRef: classroom.invitedUsersRef,
      label: classroom.label,
      colorHex: classroom.colorHex,
      messages: classroom.messages,
      createdByRef: classroom.createdByRef,
      files: classroom.files,
      folders: classroom.folders,
      createdAt: classroom.createdAt,
      updatedAt: classroom.updatedAt,
    );
    showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(title: "Adding folder", content: "Processing...");
        });
    await service.updateClassroom(updatedClassroom).then((value) async {
      classroomFolderController.clear();
      Navigator.of(dialogContext!).pop();
      Navigator.of(context).pop();
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<void> updateFolder(BuildContext context, FolderModel folder, ClassroomModel classroom) async {
    if (detectFolderChanges(folder)) {
      showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
    } else {
      BuildContext? dialogContext;
      final currentFolder = FolderModel(
        colorHex: colorToHex(folderSelectedColor!),
        folderName: classroomFolderController.text,
        createdByRef: folder.createdByRef,
        files: folder.files,
        folderId: folder.folderId,
        createdAt: folder.createdAt,
        updatedAt: DateTime.now(),
      );

      showDialog<void>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cxt) {
            dialogContext = cxt;
            return const LoadingProgressDialog(title: "Updating folder", content: "Processing...");
          });

      final folderIndex = classroom.folders!.indexWhere((e) => e.folderId == folder.folderId);
      classroom.folders![folderIndex] = currentFolder;
      await service.updateClassroom(classroom).then((value) async {
        classroomFolderController.clear();
        Navigator.of(dialogContext!).pop();
        Navigator.of(context).pop();
      }).onError((error, stackTrace) {
        Navigator.of(dialogContext!).pop();
        showingDialog(context, "errors", '$error');
      });
    }
  }

  Future<void> pickAndUploadFileAndUpdateClassroom({
    required BuildContext context,
    required ClassroomModel classroom,
    required UserModel currentUser,
    String? folderId,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        print("File picking cancelled.");
        return;
      } else {
        PlatformFile pickedFile = result.files.first;
        print("Picked file: ${pickedFile.name}");

        // showDialog(
        //   barrierDismissible: false,
        //   context: context,
        //   builder: (ctx) {
        //     dialogContext = ctx;
        //     return const LoadingProgressDialog(title: 'Uploading File...', content: "Processing");
        //   },
        // );
        String? fileUrl = await storage.uploadFileWithProgressSnackbar(
          context: context,
          classroomId: classroom.id,
          file: pickedFile,
        );
        if (fileUrl == null) {
          showingDialog(context, "File Upload Failed", "Failed to upload the file. Please try again.");
          return;
        }

        FileModel newFile = FileModel(
            fileId: const Uuid().v1(),
            fileUrl: fileUrl,
            fileType: pickedFile.extension ?? "unknown",
            senderRef: FirebaseFirestore.instance.doc('users/${currentUser.userId}'),
            fileName: pickedFile.name,
            uploadedAt: DateTime.now(),
            sender: currentUser);
        if (folderId != null) {
          List<FolderModel>? updatedFolders = classroom.folders ?? [];
          final updatedFolderIndex = updatedFolders.indexWhere((e) => e.folderId == folderId);
          List<FileModel> updatedFiles = updatedFolders[updatedFolderIndex].files!;
          updatedFiles.add(newFile);
          updatedFolders[updatedFolderIndex].files = updatedFiles;

          final updatedClassroom = ClassroomModel(
            folders: updatedFolders,
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

          await service.updateClassroom(updatedClassroom).then((value) async {
            // Navigator.of(dialogContext!).pop();
            print("Classroom updated successfully.");
          }).onError((error, stackTrace) {
            //  Navigator.of(dialogContext!).pop();
            showingDialog(context, "Error", '$error');
          });
          print("uploadinggggg inside folder");
        } else {
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

          await service.updateClassroom(updatedClassroom).then((value) async {
            //  Navigator.of(dialogContext!).pop();
            print("Classroom updated successfully.");

            print("uploadinggggg OUTSIDE folder");
          }).onError((error, stackTrace) {
            //  Navigator.of(dialogContext!).pop();
            showingDialog(context, "Error", '$error');
          });
        }
      }
    } catch (e) {
      print("Error during file picking and upload: $e");
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
        return const LoadingProgressDialog(title: 'Deleting File...', content: "Processing");
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

  Future<void> deleteFileFromFolder(BuildContext context, ClassroomModel classroom, String fileId, String folderId) async {
    BuildContext? dialogContext;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        dialogContext = ctx;
        return const LoadingProgressDialog(title: 'Deleting File...', content: "Processing");
      },
    );
    final folderIndex = classroom.folders!.indexWhere((e) => e.folderId == folderId);

    classroom.folders![folderIndex].files!.removeWhere((e) => e.fileId == fileId);
    await service.updateClassroom(classroom).then((value) async {
      Navigator.of(dialogContext!).pop();
      print("folder updated successfully.");
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      showingDialog(context, "Error", '$error');
    });
  }

  Future<void> deleteFolderFromClassroom(BuildContext context, ClassroomModel classroom, String folderId) async {
    BuildContext? dialogContext;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        dialogContext = ctx;
        return const LoadingProgressDialog(title: 'Uploading File...', content: "Processing");
      },
    );
    classroom.folders!.removeWhere((e) => e.folderId == folderId);
    await service.updateClassroom(classroom).then((value) async {
      Navigator.of(dialogContext!).pop();
      //  Navigator.of(context).pop();
      print("Classroom updated successfully.");
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      showingDialog(context, "Error", '$error');
    });
  }

  Future<void> deleteInvitedUserFromClassroom(BuildContext context, ClassroomModel classroom, String invitedUserId) async {
    BuildContext? dialogContext;
    showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(title: "Removing user", content: "Processing...");
        });

    classroom.invitedUsersRef!.removeWhere((userRef) {
      return userRef.id == invitedUserId;
    });
    await service.updateClassroom(classroom).then((value) async {
      if (dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }
    }).onError((error, stackTrace) {
      if (context.mounted) {
        showingDialog(context, "errors", '$error');
      }
    });
  }

  Future<void> downloadFileFromFirebaseWeb({
    required String firebasePath,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Firebase Storage reference
      final ref = FirebaseStorage.instance.ref(firebasePath);

      // Get the download URL from Firebase Storage
      final url = await ref.getDownloadURL();

      // Fetch the file data as an ArrayBuffer
      final response = await html.HttpRequest.request(
        url,
        responseType: 'arraybuffer',
      );

      // Convert ArrayBuffer to Uint8List
      final arrayBuffer = response.response;

      // Convert ArrayBuffer to Uint8List
      final bytes = Uint8List.view(arrayBuffer);

      // Create a Blob with the file data
      final blob = html.Blob([bytes]);

      // Create a download link for the Blob
      final downloadUrl = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element and set it up for download
      final anchor = html.AnchorElement(href: downloadUrl)
        ..target = '_self' // Open in the same window
        ..download = fileName; // Set the file name for the downloaded file

      // Trigger the click event to start the download
      anchor.click();

      // Clean up the object URL after the download is triggered
      html.Url.revokeObjectUrl(downloadUrl);

      print("Download triggered for $fileName");
    } catch (e) {
      print("Error during file download: $e");

      // Handle error (show a dialog, etc.)
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download Failed'),
            content: const Text('An error occurred while trying to download the file. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void handleCheckBoxState({bool updateState = true, required GlobalKey<DropdownSearchState<String>> popupBuilderKey, required bool? popupBuilderSelection}) {
    var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) notifyListeners();
  }

  void updatePageIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

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

  bool detectFolderChanges(FolderModel folder) {
    return folder.folderName == classroomFolderController.text && colorToHex(folderSelectedColor!) == folder.colorHex;
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

  void clearFolderControllers(BuildContext context) {
    classroomFolderController.clear();
    folderSelectedColor = Theme.of(context).colorScheme.primary;
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

  void initFolderControllers(FolderModel folder) {
    classroomFolderController.text = folder.folderName;

    folderSelectedColor = hexToColor(folder.colorHex);
  }

  void updateSelectedColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  void updateFolderSelectedColor(Color color) {
    folderSelectedColor = color;
    notifyListeners();
  }

  void updateInsideFolder(bool value) {
    isInsideFolder = value;
    notifyListeners();
  }

  void setFolder(FolderModel folder) {
    currentFolder = folder;
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
}
