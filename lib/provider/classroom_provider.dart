import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_dialog.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

class ClassroomProvider with ChangeNotifier {
  ClassroomService service = locator<ClassroomService>();
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

  // Future<void> updateCategory(
  //     BuildContext context, CategoryModel category) async {
  //   if (categoryFormKey.currentState!.validate()) {
  //     if (verifyFields(category)) {
  //       showingDialog(context, "No Changes Detected",
  //           "Please make sure to modify at least one field before attempting to update.");
  //     } else {
  //       BuildContext? dialogContext;
  //       showDialog<void>(
  //           //  barrierColor: Colors.transparent,
  //           barrierDismissible: false,
  //           context: context,
  //           builder: (BuildContext cxt) {
  //             dialogContext = cxt;
  //             return const LoadingProgressDialog(
  //               title: "Updating category",
  //               content: "processing ...",
  //             );
  //           });
  //       await service
  //           .updateCategory(CategoryModel(
  //               id: category.id,
  //               label: labelController.text,
  //               createdAt: category.createdAt,
  //               updatedAt: DateTime.now()))
  //           .then((value) async {
  //         await getCategoriesAsFuture(context).then((value) async {
  //           Navigator.of(dialogContext!).pop();
  //           Navigator.of(context).pop();
  //           clearControllers();
  //         });
  //       }).onError((error, stackTrace) {
  //         Navigator.of(dialogContext!).pop();

  //         showingDialog(context, 'Error', 'An error has occur');
  //       });
  //     }
  //   }
  // }

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

  // Future<List<CategoryModel>?> getCategoriesAsFuture(
  //     BuildContext context) async {
  //   categoriesList =
  //       await service.getCategories().catchError((error, stackTrace) {
  //     showingDialog(context, "errors", '$error');
  //     return error;
  //   });

  //   filteredCategories = categoriesList;

  //   notifyListeners();
  //   return categoriesList;
  // }

  // void filterData(
  //   String value,
  // ) {
  //   if (value.isEmpty) {
  //     categoriesList = List.from(
  //         filteredCategories!); // Reset to all categories if the search value is empty
  //   } else {
  //     categoriesList = filteredCategories!
  //         .where(
  //             (item) => item.label.toLowerCase().contains(value.toLowerCase()))
  //         .toList();
  //   }
  //   notifyListeners();
  // }

  // bool verifyFields(CategoryModel category) {
  //   return labelController.text == category.label;
  // }

  // void initControllers(CategoryModel category) {
  //   labelController.text = category.label;
  // }

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
      for (var e in selectedUsers) {
        selectedUsersIds.add(e.userId);
      }
      List<DocumentReference> invitedUsersRef = [];
      if (selectedUsersIds.isNotEmpty) {
        invitedUsersRef = selectedUsersIds.map((userId) {
          return FirebaseFirestore.instance.doc('users/$userId');
        }).toList();
      }
      print(colorToHex(selectedColor!) == classroom.colorHex);
      print("selected color hex ${colorToHex(selectedColor!)}");
      print("original color hex ${classroom.colorHex}");
      final updatedClassroom = ClassroomModel(
        id: classroom.id,
        invitedUsersRef: invitedUsersRef,
        label: classroomLabelController.text,
        colorHex: colorToHex(selectedColor!),
        comments: [],
        createdByRef: classroom.createdByRef,
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
    selectedUsers = classroom.invitedUsers!;
    selectedColor = hexToColor(classroom.colorHex);
  }

  void updateSelectedColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }
}
