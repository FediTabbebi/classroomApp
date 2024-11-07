import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/service/categories_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

class CategoryProvider with ChangeNotifier {
  CategoriesService service = locator<CategoriesService>();
  UserModel? currentUser;
  List<CategoryModel>? categoriesList = [];
  List<CategoryModel>? filteredCategories = [];
  String fliterQuery = "";
  final TextEditingController labelController = TextEditingController();
  final GlobalKey<FormState> categoryFormKey = GlobalKey<FormState>();
  List<CategoryModel> userSelectedCategory = [];
  List<CategoryModel> adminSelectedCategories = [];
  notifyUserSelectedCategory(List<CategoryModel> newCategories) {
    userSelectedCategory = newCategories;
    notifyListeners();
  }

  notifyAdminSelectedCategory(List<CategoryModel> newCategories) {
    adminSelectedCategories = newCategories;
    notifyListeners();
  }

  Future<void> addCategory(BuildContext context, CategoryModel category) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Adding category",
            content: "processing ...",
          );
        });
    await service.addCategory(category).then((value) async {
      await getCategoriesAsFuture(context).then(
        (value) {
          Navigator.of(dialogContext!).pop();
          Navigator.of(context).pop();
        },
      );
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<void> updateCategory(BuildContext context, CategoryModel category) async {
    if (categoryFormKey.currentState!.validate()) {
      if (verifyFields(category)) {
        showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
      } else {
        BuildContext? dialogContext;
        showDialog<void>(
            //  barrierColor: Colors.transparent,
            barrierDismissible: false,
            context: context,
            builder: (BuildContext cxt) {
              dialogContext = cxt;
              return const LoadingProgressDialog(
                title: "Updating category",
                content: "processing ...",
              );
            });
        await service.updateCategory(CategoryModel(id: category.id, label: labelController.text, createdAt: category.createdAt, updatedAt: DateTime.now())).then((value) async {
          await getCategoriesAsFuture(context).then((value) async {
            Navigator.of(dialogContext!).pop();
            Navigator.of(context).pop();
            clearControllers();
          });
        }).onError((error, stackTrace) {
          Navigator.of(dialogContext!).pop();

          showingDialog(context, 'Error', 'An error has occur');
        });
      }
    }
  }

  Future<void> deleteCategory(BuildContext context, String categoryId) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return const LoadingProgressDialog(
            title: "Deleting category",
            content: "processing ...",
          );
        });
    await service.deleteCategory(categoryId).then((value) async {
      await getCategoriesAsFuture(context).then(
        (value) {
          Navigator.of(dialogContext!).pop();
        },
      );
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<List<CategoryModel>?> getCategoriesAsFuture(BuildContext context) async {
    categoriesList = await service.getCategories().catchError((error, stackTrace) {
      showingDialog(context, "errors", '$error');
      return error;
    });

    filteredCategories = categoriesList;

    notifyListeners();
    return categoriesList;
  }

  void filterData(
    String value,
  ) {
    if (value.isEmpty) {
      categoriesList = List.from(filteredCategories!); // Reset to all categories if the search value is empty
    } else {
      categoriesList = filteredCategories!.where((item) => item.label.toLowerCase().contains(value.toLowerCase())).toList();
    }
    notifyListeners();
  }

  bool verifyFields(CategoryModel category) {
    return labelController.text == category.label;
  }

  void initControllers(CategoryModel category) {
    labelController.text = category.label;
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

  void clearControllers() {
    labelController.clear();
  }
}
