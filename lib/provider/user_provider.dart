import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/model/user_role.dart';
import 'package:classroom_app/service/user_management_service.dart';
import 'package:classroom_app/src/view/admin/user_management/user_management_datasource.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

class UserProvider with ChangeNotifier {
  AdminUserManagementService service = locator<AdminUserManagementService>();
  UserManagementDatasource? userManagementDataSource;

  UserModel? currentUser;
  List<UserModel> userModelList = [];
  String fliterQuery = "";

  Future<List<UserModel>> getUsersAsFuture(BuildContext context) async {
    final rslt = await service.getUsers().catchError((error, stackTrace) {
      showingDialog(context, "errors", '$error');
      return error;
    });

    userModelList = rslt.where((user) => user.userId != currentUser!.userId).toList();

    return userModelList;
  }

  Future<List<UserRole>> getAllRoles(BuildContext context) async {
    final rslt = await service.getAllRoles();

    return rslt;
  }
  // void filterData(
  //   String value,
  // ) {
  //   if (value.isEmpty) {
  //     userModelList = List.from(allusers); // Reset to all categories if the search value is empty
  //   } else {
  //     userModelList = allusers.where((item) => item.firstName.toLowerCase().contains(value.toLowerCase())).toList();
  //   }
  //   notifyListeners();
  // }

  Future<void> showingDialog(
    BuildContext context,
    String title,
    String contents,
  ) async {
    await showAnimatedDialog<void>(
        context: context,
        barrierDismissible: true,
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

  void updateUser(UserModel? user, bool withNotifier) {
    currentUser = user;

    if (withNotifier) {
      notifyListeners();
    }
  }

  void notifierProvider() {
    notifyListeners();
  }
}
