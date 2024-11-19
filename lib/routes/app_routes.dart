import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/error_page.dart';
import 'package:classroom_app/src/view/admin/admin_home_main.dart';
import 'package:classroom_app/src/view/admin/user_management/user_management.dart';
import 'package:classroom_app/src/view/instructor/instructor_home_main.dart';
import 'package:classroom_app/src/view/shared/auth/login_screen.dart';
import 'package:classroom_app/src/view/shared/auth/register_screen.dart';
import 'package:classroom_app/src/view/shared/classroom/classroom_home_main.dart';
import 'package:classroom_app/src/view/shared/classroom/classroom_screen.dart';
import 'package:classroom_app/src/view/shared/setting/edit_profile.dart';
import 'package:classroom_app/src/view/shared/setting/setting_screen.dart';
import 'package:classroom_app/src/view/shared/setting/setting_screen_web.dart';
import 'package:classroom_app/src/view/user/user_home_main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppNavigation {
  final String initSateLocation;
  final UserType userType;

  AppNavigation({required this.initSateLocation, required this.userType});

  GoRouter get router => _router;
  static final AppService appService = locator<AppService>();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final adminNavigatorKeyHome = GlobalKey<NavigatorState>(debugLabel: 'admin_home');
  static final userNavigatorKeyHome = GlobalKey<NavigatorState>(debugLabel: 'user_home');
  static final instructorNavigatorKeyHome = GlobalKey<NavigatorState>(debugLabel: 'user_home');

  late final GoRouter _router = GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      initialLocation: initSateLocation,
      refreshListenable: appService,
      routes: <RouteBase>[
        GoRoute(
            name: 'login',
            path: '/login',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  child: const LoginScreen(),
                  context: context,
                  state: state,
                )),
        GoRoute(
            name: 'register',
            path: '/register',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  child: const RegisterScreen(),
                  context: context,
                  state: state,
                )),
        StatefulShellRoute.indexedStack(
            pageBuilder: (context, state, navigationShell) => buildPageWithDefaultTransition(
                  child: AdminHomeMain(
                    navigationShell: navigationShell,
                  ),
                  context: context,
                  state: state,
                ),
            branches: [
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(
                  name: "admin-users-management",
                  path: "/admin-users-management",
                  pageBuilder: (
                    context,
                    state,
                  ) =>
                      buildPageWithDefaultTransition(
                    child: FutureProvider<List<UserModel>?>(
                        create: (context) => context.read<UserProvider>().getUsersAsFuture(context),
                        initialData: null,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<UserProvider>().getUsersAsFuture(context);
                          },
                          child: Consumer2<UserProvider, List<UserModel>?>(builder: (context, provider, userModelList, child) {
                            return UserManagementScreen(
                              usersList: userModelList,
                            );
                          }),
                        )),
                    context: context,
                    state: state,
                  ),
                ),
              ]),
              StatefulShellBranch(
                  navigatorKey: adminNavigatorKeyHome,
                  // initialLocation: "/user-dashboard",
                  routes: <RouteBase>[
                    GoRoute(
                        name: "admin-classrooms-management",
                        path: "/admin-classrooms-management",
                        pageBuilder: (
                          context,
                          state,
                        ) =>
                            buildPageWithDefaultTransition(
                              child: const ClassroomScreen(),
                              context: context,
                              state: state,
                              // PostManagementScreen(),
                            ),
                        routes: [
                          GoRoute(
                            name: "admin-classroom-details",
                            path: "admin-classroom-details/:classroomId",
                            pageBuilder: (context, state) {
                              final String classroomId = state.pathParameters["classroomId"]!;
                              return CustomTransitionPage(
                                  key: state.pageKey,
                                  child: ClassroomHomeMain(
                                    classroomId: classroomId,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 150),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                                      position: animation.drive(
                                        Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).chain(CurveTween(curve: Curves.easeInOut)),
                                      ),
                                      // textDirection:
                                      //    leftToRight ? TextDirection.ltr : TextDirection.rtl,
                                      child: child));
                            },
                          ),
                        ]),
                  ]),
              if (appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "admin-settings",
                      path: "/admin-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: UserSettingsScreen(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "adminProfile",
                          path: "adminProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ]),
              if (!appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "admin-settings",
                      path: "/admin-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: const SettingScreenWeb(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "adminProfile",
                          path: "adminProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ]),
            ]),
        StatefulShellRoute.indexedStack(
            pageBuilder: (context, state, navigationShell) => buildPageWithDefaultTransition(
                  child: PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) {
                      print(didPop);
                    },
                    child: InstructorHomeMain(
                      navigationShell: navigationShell,
                    ),
                  ),
                  context: context,
                  state: state,
                ),
            branches: [
              StatefulShellBranch(
                  navigatorKey: instructorNavigatorKeyHome,
                  // initialLocation: "/user-dashboard",
                  routes: <RouteBase>[
                    GoRoute(
                        name: "instructor-classrooms",
                        path: "/instructor-myclassrooms",
                        pageBuilder: (
                          context,
                          state,
                        ) =>
                            buildPageWithDefaultTransition(
                              child: const ClassroomScreen(),
                              context: context,
                              state: state,
                              // PostManagementScreen(),
                            ),
                        routes: [
                          GoRoute(
                            name: "instructor-classroom-details",
                            path: "instructor-classroom-details/:classroomId",
                            pageBuilder: (context, state) {
                              final String classroomId = state.pathParameters["classroomId"]!;
                              return CustomTransitionPage(
                                  key: state.pageKey,
                                  child: ClassroomHomeMain(
                                    classroomId: classroomId,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 150),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                                      position: animation.drive(
                                        Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).chain(CurveTween(curve: Curves.easeInOut)),
                                      ),
                                      // textDirection:
                                      //    leftToRight ? TextDirection.ltr : TextDirection.rtl,
                                      child: child));
                            },
                          ),
                        ]),
                  ]),
              if (appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "instructor-settings",
                      path: "/instructor-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: UserSettingsScreen(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "instructorEditProfile",
                          path: "instructorEditProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ]),
              if (!appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "instructor-settings",
                      path: "/instructor-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: const SettingScreenWeb(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "instructorEditProfile",
                          path: "instructorrEditProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ])
            ]),
        StatefulShellRoute.indexedStack(
            pageBuilder: (context, state, navigationShell) => buildPageWithDefaultTransition(
                  child: PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) {
                      print(didPop);
                    },
                    child: UserHomeMain(
                      navigationShell: navigationShell,
                    ),
                  ),
                  context: context,
                  state: state,
                ),
            branches: [
              StatefulShellBranch(
                  navigatorKey: userNavigatorKeyHome,
                  // initialLocation: "/user-dashboard",
                  routes: <RouteBase>[
                    GoRoute(
                        name: "myclassrooms",
                        path: "/user-myclassrooms",
                        pageBuilder: (
                          context,
                          state,
                        ) =>
                            buildPageWithDefaultTransition(
                              child: const ClassroomScreen(),
                              context: context,
                              state: state,
                              // PostManagementScreen(),
                            ),
                        routes: [
                          GoRoute(
                            name: "user-classroom-details",
                            path: "user-classroom-details/:classroomId",
                            pageBuilder: (context, state) {
                              final String classroomId = state.pathParameters["classroomId"]!;
                              return CustomTransitionPage(
                                  key: state.pageKey,
                                  child: ClassroomHomeMain(
                                    classroomId: classroomId,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 150),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                                      position: animation.drive(
                                        Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).chain(CurveTween(curve: Curves.easeInOut)),
                                      ),
                                      // textDirection:
                                      //    leftToRight ? TextDirection.ltr : TextDirection.rtl,
                                      child: child));
                            },
                          ),
                        ]),
                  ]),
              if (appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "user-settings",
                      path: "/user-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: UserSettingsScreen(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "userEditProfile",
                          path: "userEditProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ]),
              if (!appService.isMobileDevice)
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      name: "user-settings",
                      path: "/user-settings",
                      pageBuilder: (
                        context,
                        state,
                      ) =>
                          buildPageWithDefaultTransition(
                            child: const SettingScreenWeb(),
                            context: context,
                            state: state,
                          ),
                      routes: [
                        GoRoute(
                          name: "userEditProfile",
                          path: "userEditProfile",
                          pageBuilder: (
                            context,
                            state,
                          ) =>
                              buildPageWithDefaultTransition(
                            child: const EditProfileScreen(),
                            context: context,
                            state: state,
                          ),
                          onExit: (context) async {
                            context.read<UpdateUserProvider>().onExitReinitControllers(context);
                            return true;
                          },
                        )
                      ])
                ])
            ]),
      ],
      errorBuilder: (context, state) {
        return const ErrorPage();
      },
      redirect: (context, state) => appService.redirectionHandler(context, state));
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
  );
}
