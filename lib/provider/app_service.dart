import 'dart:async';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum UserType { admin, user, instructor }

class AppService extends ChangeNotifier {
  static final AuthenticationServices getUser = locator<AuthenticationServices>();
  UserProvider userProvider = locator<UserProvider>();
  final SharedPrefs prefs = locator<SharedPrefs>();
  bool isMobileDevice = false;
  UserModel? currentUser;
  UserType userType = UserType.admin;
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

          if (currentUser!.role!.id == "1") {
            userType = UserType.admin;
            initHomeLocation = "/admin-users-management";
          } else if (currentUser!.role!.id == "2") {
            userType = UserType.instructor;
            initHomeLocation = "/instructor-myclassrooms";
          } else {
            userType = UserType.user;
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
    final adminRoutes = state.fullPath!.contains('admin');
    final userRoutes = state.fullPath!.contains('/user');
    final instructorRoutes = state.fullPath!.contains('instructor');
    final isLogedIn = currentUser != null;
    final isGoingToLogin = state.matchedLocation == loginLocation;
    final isGoingToRegister = state.matchedLocation == registerLocation;
    // final isGoingToLanding = state.matchedLocation == landingLocation;

    if (isLogedIn) {
      if (isGoingToLogin) {
        return initHomeLocation;
      }
      if (userType == UserType.admin && !adminRoutes) {
        return adminRoutes ? null : initHomeLocation;
      }
      if (userType == UserType.instructor && !instructorRoutes) {
        return instructorRoutes ? null : initHomeLocation;
      }
      if (userType == UserType.user && !userRoutes) {
        return userRoutes ? null : initHomeLocation;
      }

      return null;
    } else if (isGoingToRegister) {
      return registerLocation;
    } else if (isGoingToLogin) {
      return loginLocation;
    }
    // else if (isGoingToLanding) {
    //   return landingLocation;
    // }
    else {
      return loginLocation;
    }
  }
}
