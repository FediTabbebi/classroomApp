import 'dart:async';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum UserType {
  admin,
  user,
}

class AppService extends ChangeNotifier {
  static final AuthenticationServices getUser = locator<AuthenticationServices>();
  UserProvider userProvider = locator<UserProvider>();
  final SharedPrefs prefs = locator<SharedPrefs>();
  bool isMobileDevice = false;
  UserModel? currentUser;
  UserType userRole = UserType.admin;
  String initHomeLocation = "/login";

  Future<bool> authNotifier() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    isMobileDevice = await platformChecker(deviceInfo);
    String? userId = prefs.getUserId();
    if (userId != null) {
      await getUser.getCurrentUser(userId).then((value) {
        if (!value!.isDeleted) {
          currentUser = value;
          userProvider.updateUser(currentUser!, false);

          if (currentUser!.role == "Admin") {
            userRole = UserType.admin;
            initHomeLocation = "/admin-users-management";
          } else {
            userRole = UserType.user;
            initHomeLocation = "/user-myclassrooms";
          }
        }
      }).onError((error, stackTrace) => currentUser = null);
    } else {
      if (kDebugMode) {
        print("User has signed out");
      }
      currentUser = null;
    }

    notifyListeners();
    return true;
  }

  // Future<void> waitForAuthChange() {
  //   return _authCompleter.future;
  // }

  FutureOr<String?> redirectionHandler(BuildContext context, GoRouterState state) async {
    final loginLocation = state.namedLocation("login");
    // final landingLocation = state.namedLocation("polyscrum");
    final registerLocation = state.namedLocation("register");

    final adminRoutes = state.fullPath!.startsWith('admin') || state.fullPath!.startsWith('/admin');
    final userRoutes = state.fullPath!.startsWith('/user');

    final isLogedIn = currentUser != null;
    final isGoingToLogin = state.matchedLocation == loginLocation;
    final isGoingToRegister = state.matchedLocation == registerLocation;
    // final isGoingToLanding = state.matchedLocation == landingLocation;

    if (isLogedIn) {
      if (isGoingToLogin) {
        return initHomeLocation;
      }
      if (userRole == UserType.admin && !adminRoutes) {
        return initHomeLocation;
      }
      if (userRole == UserType.user && !userRoutes) {
        return initHomeLocation;
      }

      return null;
    } else if (isGoingToRegister) {
      return registerLocation;
    }
    // else if (isGoingToLanding) {
    //   return landingLocation;
    // }
    return loginLocation;
  }
}
