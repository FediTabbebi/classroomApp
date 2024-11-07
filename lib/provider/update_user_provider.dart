import 'dart:io';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/service/storage_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_dialog.dart';
import 'package:classroom_app/utils/exception_handler.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateUserProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> createUserFormKey = GlobalKey<FormState>();
  UserProvider userProvider = locator<UserProvider>();
  StorageService storage = locator<StorageService>();
  AuthenticationServices authService = locator<AuthenticationServices>();
  DateTime selectedDate = DateTime.now();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordFieldVisibility = false;
  bool isLoading = false;
  bool isObscure = false;
  String imageURL = '';
  Uint8List? imageData;
  File? userCreationImg;
  File? imageDataMobile;
  String? selectedUserRole;

  final userRoleMultiKey = GlobalKey<DropdownSearchState<String>>();
  final GlobalKey<DropdownSearchState<String>> popupBuilderKey = GlobalKey<DropdownSearchState<String>>();

  bool? popupBuilderSelection = false;
  List<String> userRole = [
    'Admin',
    'User',
  ];

  void handleCheckBoxState({bool updateState = true}) {
    var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) notifyListeners();
  }

  updateProfile(BuildContext context, File? userImg) async {
    if (kIsWeb) {
      if (formKey.currentState!.validate()) {
        if (verifyFields() && imageData == null) {
          showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
        } else {
          if (imageData != null) {
            await updateUserAndUploadImage(context, imageData!);
          } else {
            updateUserWithoutUploadingImg(context);
          }
        }
      }
    } else {
      if (formKey.currentState!.validate()) {
        if (verifyFields() && userImg == null) {
          showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
        } else {
          if (userImg != null) {
            await updateUserAndUploadImage(context, userImg.readAsBytesSync());
          } else {
            updateUserWithoutUploadingImg(context);
          }
        }
      }
    }
  }

  Future<void> updateUserWithoutUploadingImg(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    await authService
        .updateUser(UserModel(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            profilePicture: userProvider.currentUser!.profilePicture,
            role: userProvider.currentUser!.role,
            password: userProvider.currentUser!.password,
            userId: userProvider.currentUser!.userId,
            createdAt: userProvider.currentUser!.createdAt,
            updatedAt: DateTime.now(),
            isDeleted: userProvider.currentUser!.isDeleted))
        .then((value) async {
      await authService.getAuthUser().then((value) async {
        clearControllers();
        userProvider.updateUser(value!, true);
        settingControllers();
        isLoading = false;
        notifyListeners();
        showingDialog(context, 'Success', 'Your profile has been updated');
      });
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      showingDialog(context, 'Error', 'An error has occured');
    });
  }

  Future<void> updateUserAndUploadImage(BuildContext context, Uint8List imageData) async {
    isLoading = true;
    notifyListeners();
    await storage.uploadImage(imageData, '${userProvider.currentUser!.firstName}-${userProvider.currentUser!.userId}', 'Profile Images').then((value) async {
      imageURL = value;
      await authService
          .updateUser(UserModel(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              email: emailController.text,
              profilePicture: imageURL,
              role: userProvider.currentUser!.role,
              password: userProvider.currentUser!.password,
              userId: userProvider.currentUser!.userId,
              createdAt: userProvider.currentUser!.createdAt,
              updatedAt: DateTime.now(),
              isDeleted: userProvider.currentUser!.isDeleted))
          .then((value) async {
        await authService.getAuthUser().then((value) {
          clearControllers();
          userProvider.updateUser(value!, true);
          settingControllers();
          isLoading = false;
          notifyListeners();
          showingDialog(context, 'Success', 'Your profile has been updated');
        });
      }).onError((error, stackTrace) {
        isLoading = false;
        notifyListeners();
        showingDialog(context, 'Error', 'An error has occur');
      });
    });
  }

  Future<void> createNewUser(UserModel user, BuildContext context, GlobalKey<FormState> formKey, File? img) async {
    if (formKey.currentState!.validate()) {
      BuildContext? dialogContext;
      showDialog<void>(
          //  barrierColor: Colors.transparent,
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cxt) {
            dialogContext = cxt;
            return const LoadingProgressDialog(
              title: "Adding new user",
              content: "Processing ...",
            );
          });
      if (img != null) {
        await storage.uploadImage(img.readAsBytesSync(), '${user.firstName}-${user.lastName}', 'Profile Images').then((value) async {
          imageURL = value;
          return await authService.registerUser(user: user, profilePicture: imageURL).then((value) async {
            await context.read<UserProvider>().getUsersAsFuture(context).then((value) {
              isLoading = false;
              clearControllers();
              notifyListeners();
              Navigator.of(dialogContext!).pop();
              Navigator.of(context).pop();
            });
          }).onError((error, stackTrace) {
            Navigator.of(dialogContext!).pop();

            String errorMessage;
            if (error is FirebaseAuthException) {
              errorMessage = ExceptionHandler.getFirebaseErrorMessage(error);
              showingDialog(context, "An an error has occured\nwhile creating user", errorMessage);
            }
          });
        }).onError((error, stackTrace) {
          Navigator.of(dialogContext!).pop();
          String errorMessage;
          if (error is FirebaseAuthException) {
            errorMessage = ExceptionHandler.getFirebaseErrorMessage(error);
            showingDialog(context, "An an error has occured\nwhile uploading picture", errorMessage);
          }
        });
      } else {
        await authService.registerUser(user: user).then((value) async {
          Navigator.of(dialogContext!).pop();
          Navigator.of(context).pop();
          clearControllers();
          notifyListeners();
        }).onError((error, stackTrace) {
          Navigator.of(dialogContext!).pop();
          String errorMessage;
          if (error is FirebaseAuthException) {
            errorMessage = ExceptionHandler.getFirebaseErrorMessage(error);
            showingDialog(context, "An an error has occured\nwhile creating user", errorMessage);
          }
        });
      }
    }
  }

  Future<void> banOrUnbanUser(BuildContext context, UserModel user) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return LoadingProgressDialog(
            title: "${user.isDeleted ? "Unabanning" : "Banning"} User",
            content: "processing ...",
          );
        });
    await authService
        .updateUser(UserModel(
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.profilePicture,
            role: user.role,
            password: user.password,
            userId: user.userId,
            createdAt: user.createdAt,
            updatedAt: DateTime.now(),
            isDeleted: user.isDeleted ? false : true))
        .then((value) async {
      await context.read<UserProvider>().getUsersAsFuture(context).then((value) => Navigator.of(dialogContext!).pop());
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, 'Fail', 'An error has occured while updating user');
    });
  }

  Future<void> pickImage(bool isRegister) async {
    try {
      ImagePicker imagePicker = ImagePicker();
      final file = await imagePicker.pickImage(source: ImageSource.gallery);

      if (file == null) {
        if (kDebugMode) {
          print('No image selected.');
        }
      }

      if (!kIsWeb) {
        final imageFile = file;
        if (kDebugMode) {
          print(' image selected.');
        }
        if (isRegister) {
          imageDataMobile = File(imageFile!.path);
        } else {
          userCreationImg = File(imageFile!.path);
        }

        if (kDebugMode) {
          print(imageFile.path);
        }
        notifyListeners();
      } else {
        imageData = await file?.readAsBytes();

        notifyListeners();
      }
    } catch (e) {
      // If there is an error, show a snackBar with the error message
    }
  }

  void removeImg(bool isRegister) {
    isRegister ? imageDataMobile = null : userCreationImg = null;

    notifyListeners();
  }

  setObscureField() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void setPasswordFieldVisibility() {
    passwordFieldVisibility = !passwordFieldVisibility;
    notifyListeners();
  }

  bool verifyFields() {
    return firstNameController.text == userProvider.currentUser!.firstName && lastNameController.text == userProvider.currentUser!.lastName && emailController.text == userProvider.currentUser!.email;
  }

  bool verifyFieldsWithRole(UserModel user) {
    return firstNameController.text == user.firstName && lastNameController.text == user.lastName && selectedUserRole == user.role;
  }

  void settingControllers() {
    firstNameController.text = userProvider.currentUser?.firstName ?? "";
    lastNameController.text = userProvider.currentUser?.lastName ?? "";
    emailController.text = userProvider.currentUser?.email ?? "";
    imageURL = userProvider.currentUser?.profilePicture ?? "";
  }

  void initControllers(UserModel user) {
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    selectedUserRole = user.role;
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    imageURL = "";
    imageData = null;
    imageDataMobile = null;
    userCreationImg = null;
  }

  Future<void> showingDialog(
    BuildContext context,
    String title,
    String contents,
  ) async {
    BuildContext localContext = context;
    await showAnimatedDialog<void>(
        barrierDismissible: true,
        animationType: DialogTransitionType.scale,
        context: localContext,
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: title,
            dialogContent: contents,
          );
        });
  }

  /////////////////////////////////////////////////////////////////////

  void updateUser(BuildContext context, UserModel user, File? userImg) async {
    if (createUserFormKey.currentState!.validate()) {
      if (verifyFieldsWithRole(user) && userImg == null) {
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
                title: "Updating user",
                content: "processing ...",
              );
            });
        if (userImg != null) {
          await adminupdateUserAndUploadImage(context, userImg.readAsBytesSync(), user).then((value) {
            Navigator.of(dialogContext!).pop();
            Navigator.of(context).pop();
          }).onError((error, stackTrace) {
            Navigator.of(context).pop();
            showingDialog(context, 'Error', 'An error has occured');
          });
        } else {
          adminUpdateUserWithoutUploadingImage(
            context,
            user,
          ).then((value) {
            Navigator.of(dialogContext!).pop();
            Navigator.of(context).pop();
          }).onError((error, stackTrace) {
            Navigator.of(context).pop();
            showingDialog(context, 'Error', 'An error has occured');
          });
        }
      }
    }
  }

  Future<void> adminUpdateUserWithoutUploadingImage(
    BuildContext context,
    UserModel user,
  ) async {
    await authService
        .updateUser(UserModel(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            profilePicture: user.profilePicture,
            role: selectedUserRole!,
            password: user.password,
            userId: user.userId,
            createdAt: user.createdAt,
            updatedAt: DateTime.now(),
            isDeleted: user.isDeleted))
        .then((value) async {
      await context.read<UserProvider>().getUsersAsFuture(context).then((value) async {
        clearControllers();
      });
    });
  }

  Future<void> adminupdateUserAndUploadImage(
    BuildContext context,
    Uint8List imageData,
    UserModel user,
  ) async {
    isLoading = true;
    notifyListeners();
    await storage.uploadImage(imageData, '${user.firstName}-${user.userId}', 'Profile Images').then((value) async {
      imageURL = value;
      await authService
          .updateUser(UserModel(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              email: emailController.text,
              profilePicture: imageURL,
              role: selectedUserRole!,
              password: user.password,
              userId: user.userId,
              createdAt: user.createdAt,
              updatedAt: DateTime.now(),
              isDeleted: user.isDeleted))
          .then((value) async {
        await context.read<UserProvider>().getUsersAsFuture(context).then((value) {});
      });
    });
  }
}
