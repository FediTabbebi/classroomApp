import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/view/shared/sidebar_widget.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InstructorHomeMain extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  InstructorHomeMain({required this.navigationShell, super.key});
  final ClassroomService service = locator<ClassroomService>();

  @override
  Widget build(BuildContext context) {
    const List<NavItemModel> menuItems = [
      NavItemModel(name: 'Classrooms', icon: FontAwesomeIcons.sheetPlastic),
    ];
    return SafeArea(
      child: Scaffold(
          body: StreamProvider<List<ClassroomModel>?>(
            create: (context) => service.getAllClassroomAsStream(
              context.read<UserProvider>().currentUser!.role!.id,
              context.read<UserProvider>().currentUser!.userId,
              context,
            ),
            initialData: null,
            child: !context.read<AppService>().isMobileDevice
                ? SideBarWidget(
                    navigationShell: navigationShell,
                    menuItems: menuItems,
                  )
                : navigationShell,
          ),
          bottomNavigationBar: context.read<AppService>().isMobileDevice
              ? Visibility(
                  visible: (navigationShell.shellRouteContext.routerState.fullPath != "/user-second-page/post-details" &&
                      navigationShell.shellRouteContext.routerState.fullPath != "/user-post-screen/my-post-details"),
                  child: FlashyTabBar(
                    selectedIndex: navigationShell.currentIndex,
                    showElevation: true,
                    onItemSelected: (index) {
                      goToBranch(index);
                    },
                    backgroundColor: Theme.of(context).cardTheme.color,
                    items: [
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(FontAwesomeIcons.sheetPlastic),
                        title: const Text('Classrooms'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(FontAwesomeIcons.gear),
                        title: const Text('Settings'),
                      ),
                    ],
                  ),
                )
              : null),
    );
  }

  goToBranch(index) {
    navigationShell.goBranch(index);
  }
}
