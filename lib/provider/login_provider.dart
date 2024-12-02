import 'package:classroom_app/locator.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/exception_handler.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:go_router/go_router.dart';

class LoginProvider with ChangeNotifier {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(text: "admin@pi.tn");
  final TextEditingController passwordController = TextEditingController(text: "adminPi");
  bool isLoading = false;
  bool isObscure = true;
  bool passwordFieldVisibility = false;
  final AuthenticationServices authService = locator<AuthenticationServices>();
  AppService appService = locator<AppService>();
  final SharedPrefs prefs = locator<SharedPrefs>();
  UserProvider userProvider = locator<UserProvider>();

  Future<void> loginUser(String email, String password, BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();
      await authService.signInWithEmailAndPassword(email, password).then((value) async {
        isLoading = false;
        if (value!.isDeleted) {
          showDialogMessage(context, "Your account has been banned\nplease contact support at\nautistic@gmail.com");
        } else {
          await prefs.saveUserId(value.userId);
          await appService.authNotifier();

          clearControllers();
          notifyListeners();
        }
      }).onError((error, stackTrace) {
        isLoading = false;
        notifyListeners();
        String errorMessage;
        if (error is FirebaseAuthException) {
          errorMessage = ExceptionHandler.getFirebaseErrorMessage(error);
          showDialogMessage(context, errorMessage);
        }
      });
    }
  }

  Future<void> signoutUser() async {
    await prefs.removeUserId();
    userProvider.updateUser(null, false);
    await appService.authNotifier();
  }

  setObscureField() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void setPasswordFieldVisibility() {
    passwordFieldVisibility = !passwordFieldVisibility;
    notifyListeners();
  }

  Future<void> showDialogMessage(BuildContext context, String message) async {
    await showAnimatedDialog<void>(
        animationType: DialogTransitionType.scale,
        context: context,
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: "An Error Occured",
            dialogContent: message,
            onConfirm: () {
              context.pop();
            },
          );
        });
  }

  clearControllers() {
    emailController.clear();
    passwordController.clear();
  }
}
