import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/download_helper.dart';
import 'package:classroom_app/provider/login_provider.dart';
import 'package:classroom_app/provider/message_provider.dart';
import 'package:classroom_app/provider/register_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/provider/upload_helper.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/service/classroom_service.dart';
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
  locator.registerLazySingleton(() => LoginProvider());
  locator.registerLazySingleton(() => RegisterProvider());
  locator.registerLazySingleton(() => UserProvider());
  locator.registerLazySingleton(() => UpdateUserProvider());
  locator.registerLazySingleton(() => ClassroomProvider());
  locator.registerLazySingleton(() => MessageProvider());
  //services
  locator.registerLazySingleton(() => SharedPrefs());
  locator.registerLazySingleton(() => AuthenticationServices());
  locator.registerLazySingleton(() => AdminUserManagementService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => ClassroomService());
  locator.registerLazySingleton(() => FileDownloadHelper());
  locator.registerLazySingleton(() => UploadHelper());

  // locator.registerLazySingleton(() => UserDataProvider());
}
