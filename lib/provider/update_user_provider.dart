import 'dart:io';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/role_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/service/storage_service.dart';
import 'package:classroom_app/src/view/admin/user_management/user_management_datasource.dart';
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

  RoleModel? selectedroleModel;

  final roleModelMultiKey = GlobalKey<DropdownSearchState<String>>();
  final GlobalKey<DropdownSearchState<String>> popupBuilderKey = GlobalKey<DropdownSearchState<String>>();

  bool? popupBuilderSelection = false;

  void handleCheckBoxState({bool updateState = true}) {
    var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) notifyListeners();
  }

  updateProfile(BuildContext context, File? userImg, String roleModelId) async {
    if (kIsWeb) {
      if (formKey.currentState!.validate()) {
        if (verifyFields() && imageData == null) {
          showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
        } else {
          if (imageData != null) {
            await updateUserAndUploadImage(context, imageData!, roleModelId);
          } else {
            updateUserWithoutUploadingImg(context, roleModelId);
          }
        }
      }
    } else {
      if (formKey.currentState!.validate()) {
        if (verifyFields() && userImg == null) {
          showingDialog(context, "No Changes Detected", "Please make sure to modify at least one field before attempting to update.");
        } else {
          if (userImg != null) {
            await updateUserAndUploadImage(context, userImg.readAsBytesSync(), roleModelId);
          } else {
            updateUserWithoutUploadingImg(context, roleModelId);
          }
        }
      }
    }
  }

  Future<void> updateUserWithoutUploadingImg(BuildContext context, String roleModelId) async {
    isLoading = true;
    notifyListeners();

    await authService
        .updateUser(
            UserModel(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                profilePicture: userProvider.currentUser!.profilePicture,
                role: userProvider.currentUser!.role,
                roleRef: userProvider.currentUser!.roleRef,
                password: userProvider.currentUser!.password,
                userId: userProvider.currentUser!.userId,
                createdAt: userProvider.currentUser!.createdAt,
                updatedAt: DateTime.now(),
                isDeleted: userProvider.currentUser!.isDeleted),
            roleModelId)
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

  Future<void> updateUserAndUploadImage(BuildContext context, Uint8List imageData, String roleModelId) async {
    isLoading = true;
    notifyListeners();
    await storage.uploadImage(imageData, '${userProvider.currentUser!.firstName}-${userProvider.currentUser!.userId}', 'Profile Images').then((value) async {
      imageURL = value;
      await authService
          .updateUser(
              UserModel(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  profilePicture: imageURL,
                  role: userProvider.currentUser!.role,
                  roleRef: userProvider.currentUser!.roleRef,
                  password: userProvider.currentUser!.password,
                  userId: userProvider.currentUser!.userId,
                  createdAt: userProvider.currentUser!.createdAt,
                  updatedAt: DateTime.now(),
                  isDeleted: userProvider.currentUser!.isDeleted),
              roleModelId)
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

  Future<void> createNewUser(
    UserModel user,
    BuildContext context,
    File? img,
  ) async {
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
      await storage.uploadImage(imageData!, '${user.firstName}-${user.lastName}', 'Profile Images').then((value) async {
        imageURL = value;
        return await authService
            .registerUser(
          user: user,
          profilePicture: imageURL,
        )
            .then((value) async {
          await context.read<UserProvider>().getUsersAsFuture(context).then((allUser) {
            isLoading = false;
            context.read<UserProvider>().userModelList = allUser;
            if (context.read<UserProvider>().userManagementDataSource == null) {
              context.read<UserProvider>().userManagementDataSource = UserManagementDatasource(users: allUser, context: context);
            }
            context.read<UserProvider>().userManagementDataSource!.updateDataGridSource();
            context.read<UserProvider>().notifierProvider();
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
      await authService
          .registerUser(
        user: user,
      )
          .then((value) async {
        await context.read<UserProvider>().getUsersAsFuture(context).then((value) {
          context.read<UserProvider>().userModelList = value;
          context.read<UserProvider>().userManagementDataSource!.updateDataGridSource();
          context.read<UserProvider>().notifierProvider();
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
    }
  }

  Future<void> banOrUnbanUser(BuildContext context, UserModel user, String roleModelId) async {
    BuildContext? dialogContext;
    showDialog<void>(
        //  barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext cxt) {
          dialogContext = cxt;
          return LoadingProgressDialog(
            title: "${user.isDeleted ? "Unbanning" : "Banning"} User",
            content: "processing ...",
          );
        });
    await authService
        .updateUser(
            UserModel(
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                profilePicture: user.profilePicture,
                role: user.role,
                roleRef: userProvider.currentUser!.roleRef,
                password: user.password,
                userId: user.userId,
                createdAt: user.createdAt,
                updatedAt: DateTime.now(),
                isDeleted: user.isDeleted ? false : true),
            roleModelId)
        .then((value) async {
      await context.read<UserProvider>().getUsersAsFuture(context).then((value) {
        context.read<UserProvider>().notifierProvider();
        Navigator.of(dialogContext!).pop();
      });
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
      } else {
        if (kDebugMode) {
          print(' image selected.');
        }
        if (isRegister) {
          imageDataMobile = File(file.path);
          imageData = await file.readAsBytes();
        } else {
          userCreationImg = File(file.path);
          imageData = await file.readAsBytes();
        }

        // if (kDebugMode) {
        //   print(imageFile.path);
        // }
        notifyListeners();
      }
    } catch (e) {
      // If there is an error, show a snackBar with the error message
    }
  }

  void removeImg(bool isRegister) {
    isRegister ? imageDataMobile = null : userCreationImg = null;
    imageData = null;
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
    return firstNameController.text == user.firstName && lastNameController.text == user.lastName && selectedroleModel == user.role;
  }

  void settingControllers() {
    firstNameController.text = userProvider.currentUser?.firstName ?? "";
    lastNameController.text = userProvider.currentUser?.lastName ?? "";
    emailController.text = userProvider.currentUser?.email ?? "";
    imageURL = userProvider.currentUser?.profilePicture ?? "";
    selectedroleModel = userProvider.currentUser?.role;
  }

  void initControllers(UserModel user) {
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    selectedroleModel = user.role;
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

  void updateUser(BuildContext context, UserModel user, File? userImg, String roleModelId) async {
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
        await adminupdateUserAndUploadImage(context, imageData!, user, roleModelId).then((value) {
          Navigator.of(dialogContext!).pop();
          Navigator.of(context).pop();
        }).onError((error, stackTrace) {
          Navigator.of(context).pop();
          showingDialog(context, 'Error', 'An error has occured');
        });
      } else {
        adminUpdateUserWithoutUploadingImage(context, user, roleModelId).then((value) {
          Navigator.of(dialogContext!).pop();
          Navigator.of(context).pop();
        }).onError((error, stackTrace) {
          Navigator.of(context).pop();
          showingDialog(context, 'Error', 'An error has occured');
        });
      }
    }
  }

  Future<void> adminUpdateUserWithoutUploadingImage(BuildContext context, UserModel user, String roleModelId) async {
    await authService
        .updateUser(
            UserModel(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                profilePicture: user.profilePicture,
                role: selectedroleModel!,
                password: user.password,
                roleRef: user.roleRef,
                userId: user.userId,
                createdAt: user.createdAt,
                updatedAt: DateTime.now(),
                isDeleted: user.isDeleted),
            selectedroleModel!.id)
        .then((value) async {
      await context.read<UserProvider>().getUsersAsFuture(context).then((value) async {
        context.read<UserProvider>().userModelList = value;
        context.read<UserProvider>().userManagementDataSource!.updateDataGridSource();
        context.read<UserProvider>().notifierProvider();
        clearControllers();
      });
    });
  }

  Future<void> adminupdateUserAndUploadImage(BuildContext context, Uint8List imageData, UserModel user, String roleModelId) async {
    isLoading = true;
    notifyListeners();
    await storage.uploadImage(imageData, '${user.firstName}-${user.userId}', 'Profile Images').then((value) async {
      imageURL = value;
      await authService
          .updateUser(
              UserModel(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  profilePicture: imageURL,
                  role: selectedroleModel!,
                  password: user.password,
                  roleRef: user.roleRef,
                  userId: user.userId,
                  createdAt: user.createdAt,
                  updatedAt: DateTime.now(),
                  isDeleted: user.isDeleted),
              selectedroleModel!.id)
          .then((value) async {
        await context.read<UserProvider>().getUsersAsFuture(context).then((value) {
          context.read<UserProvider>().userModelList = value;
          context.read<UserProvider>().userManagementDataSource!.updateDataGridSource();
          context.read<UserProvider>().notifierProvider();
        });
      });
    });
  }

  void onExitReinitControllers(BuildContext context) {
    final user = context.read<UserProvider>().currentUser!;
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    imageDataMobile = null;
    imageData = null;
    notifyListeners();
  }
}
