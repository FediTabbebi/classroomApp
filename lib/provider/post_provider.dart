import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/model/post_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/service/post_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

class PostProvider with ChangeNotifier {
  PostService service = locator<PostService>();
  UserModel? currentUser;
  List<CategoryModel>? categoriesList = [];
  List<CategoryModel>? filteredCategories = [];

  String fliterQuery = "";

  final TextEditingController postDescriptionController = TextEditingController();
  final TextEditingController postCategoryController = TextEditingController();
  final GlobalKey<FormState> postFormKey = GlobalKey<FormState>();
  bool isSelectFromAllCategories = false;
  bool? updating;
  CategoryModel? selectedCategory;

  final postMultiKey = GlobalKey<DropdownSearchState<String>>();
  final GlobalKey<DropdownSearchState<String>> popupBuilderKey = GlobalKey<DropdownSearchState<String>>();

  bool? popupBuilderSelection = false;
  List<CategoryModel> allCategories = [];

  void handleCheckBoxState({bool updateState = true}) {
    var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) notifyListeners();
  }

  Future<void> addPost(BuildContext context, PostModel post) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Adding new Post",
            content: "processing ...",
          );
        });
    await service.addPost(post).then((value) async {
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

  Future<void> deletePost(BuildContext context, String postId) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Deleting post",
            content: "processing ...",
          );
        });
    await service.deletePost(postId).then((value) async {
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

  void updateCategorySelection() {
    isSelectFromAllCategories = !isSelectFromAllCategories;
    notifyListeners();
  }

  void clearControllers() {
    postDescriptionController.clear();
    postDescriptionController.clear();
  }
}
