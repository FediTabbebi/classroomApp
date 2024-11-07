import 'package:classroom_app/constant/app_icons.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/post_model.dart';
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
import 'package:classroom_app/routes/app_routes.dart';
import 'package:classroom_app/service/post_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppService appService = locator<AppService>();
  final PostService service = locator<PostService>();
  ValueNotifier<bool?> authResultNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _fetchAuthData();
  }

  Future<void> _fetchAuthData() async {
    final authResult = await appService.authNotifier();
    authResultNotifier.value = authResult;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: ValueListenableBuilder<bool?>(
            valueListenable: authResultNotifier,
            builder: (context, authResult, child) {
              if (authResult == null) {
                return Center(child: Image.asset(AppIcons.appLogo));
              } else {
                AppNavigation appNavigation = AppNavigation(initSateLocation: appService.initHomeLocation, userType: appService.userRole);

                return StreamProvider<List<PostModel>?>(
                    create: (context) => service.getAllPostsAsStream(context.read<UserProvider>().currentUser!.userId, context),
                    initialData: null,
                    builder: (context, child) => Selector<ThemeProvider, bool>(
                        selector: (p0, p1) => p1.isDarkMode,
                        builder: (context, isDarkMode, child) {
                          return MaterialApp.router(
                            theme: context.read<ThemeProvider>().getThemeData(),
                            debugShowCheckedModeBanner: false,
                            routerConfig: appNavigation.router,
                          );
                        }));
              }
            }));
  }
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => locator<ThemeProvider>()),
  ChangeNotifierProvider(create: (_) => locator<AppService>()),
  ChangeNotifierProvider(create: (_) => locator<RegisterProvider>()),
  ChangeNotifierProvider(create: (_) => locator<LoginProvider>()),
  ChangeNotifierProvider(create: (_) => locator<UserProvider>()),
  ChangeNotifierProvider(create: (_) => locator<UpdateUserProvider>()),
  ChangeNotifierProvider(create: (_) => locator<CategoryProvider>()),
  ChangeNotifierProvider(create: (_) => locator<PostProvider>()),
  ChangeNotifierProvider(create: (_) => locator<CommentProvider>()),
  ChangeNotifierProvider(create: (_) => locator<DashboardProvider>()),
];
