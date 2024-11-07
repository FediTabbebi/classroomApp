import 'package:classroom_app/app.dart';
import 'package:classroom_app/firebase_options.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();
  await locator<SharedPrefs>().init();

  runApp(const MyApp());
}
