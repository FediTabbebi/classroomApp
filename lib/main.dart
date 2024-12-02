import 'package:classroom_app/app.dart';
import 'package:classroom_app/firebase_options.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/provider/download_helper.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
//import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // setPathUrlStrategy();
  setupLocator();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  final downloadHelper = FileDownloadHelper();
  await downloadHelper.initializeNotifications();
  await locator<SharedPrefs>().init();
  runApp(const MyApp());
}
