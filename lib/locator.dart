import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/category_provider.dart';
import 'package:classroom_app/provider/comment_provider.dart';
import 'package:classroom_app/provider/login_provider.dart';
import 'package:classroom_app/provider/post_provider.dart';
import 'package:classroom_app/provider/register_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/provider/user/dashboard_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/service/categories_service.dart';
import 'package:classroom_app/service/post_service.dart';
import 'package:classroom_app/service/storage_service.dart';
import 'package:classroom_app/service/user_management_service.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

setupLocator() {
  locator.registerLazySingleton(() {
    return AppService();
  });
//providers
  locator.registerLazySingleton(() => ThemeProvider());
  locator.registerLazySingleton(() => DashboardProvider());
  locator.registerLazySingleton(() => LoginProvider());
  locator.registerLazySingleton(() => RegisterProvider());
  locator.registerLazySingleton(() => UserProvider());
  locator.registerLazySingleton(() => CategoryProvider());
  locator.registerLazySingleton(() => UpdateUserProvider());
  locator.registerLazySingleton(() => PostProvider());
  locator.registerLazySingleton(() => CommentProvider());
  //services
  locator.registerLazySingleton(() => SharedPrefs());
  locator.registerLazySingleton(() => AuthenticationServices());
  locator.registerLazySingleton(() => AdminUserManagementService());
  locator.registerLazySingleton(() => CategoriesService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => PostService());

  // locator.registerLazySingleton(() => UserDataProvider());
}
