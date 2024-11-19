import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/exception_handler.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:go_router/go_router.dart';

class RegisterProvider with ChangeNotifier {
  final AuthenticationServices authService = locator<AuthenticationServices>();
  AppService appService = locator<AppService>();
  final SharedPrefs prefs = locator<SharedPrefs>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool passwordFieldVisibility = false;
  bool isLoading = false;
  bool isObscure = false;

  Future<void> registerUser(UserModel user, BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();
      await authService
          .registerUser(
        user: user,
      )
          .then((value) {
        isLoading = false;
        clearControllers();

        if (context.mounted) {
          context.pushNamed("login");
        }
        Future.delayed(const Duration(milliseconds: 150), () {
          showDialogMessage(context, "Success", "Your account has been created\nsuccessfully");
        });

        notifyListeners();
      }).onError((error, stackTrace) {
        isLoading = false;
        notifyListeners();
        String errorMessage;
        if (error is FirebaseAuthException) {
          errorMessage = ExceptionHandler.getFirebaseErrorMessage(error);
          showDialogMessage(context, "An Error Occured", errorMessage);
        }
      });
    }
  }

  setObscureField() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void setPasswordFieldVisibility() {
    passwordFieldVisibility = !passwordFieldVisibility;
    notifyListeners();
  }

  resetTextFieldsControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    passwordFieldVisibility = false;
  }

  Future<void> showDialogMessage(BuildContext context, String dialogTitle, String message) async {
    await showAnimatedDialog<void>(
        animationType: DialogTransitionType.scale,
        context: context,
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: dialogTitle,
            dialogContent: message,
            onConfirm: () {
              context.pop();
            },
          );
        });
  }

  clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
