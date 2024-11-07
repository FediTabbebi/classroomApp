import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/src/view/shared/sidebar_widget.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminHomeMain extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AdminHomeMain({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
            children: [
              if (!context.read<AppService>().isMobileDevice)
                SideBarWidget(
                  navigationShell: navigationShell,
                ),
              Expanded(child: navigationShell),
            ],
          ),
          bottomNavigationBar: context.read<AppService>().isMobileDevice
              ? Visibility(
                  visible: navigationShell.shellRouteContext.routerState.fullPath != "/admin-second-page/admin-post-details",
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
                        icon: const Icon(FontAwesomeIcons.userGroup),
                        title: const Text('users'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.forum),
                        title: const Text('Forum'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(FontAwesomeIcons.tags),
                        title: const Text('Category'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.settings),
                        title: const Text('Settings'),
                      ),
                      // FlashyTabBarItem(
                      //   activeColor: Theme.of(context).colorScheme.primary,
                      //   icon: const Icon(Icons.settings),
                      //   title: const Text('settings'),
                      // ),
                    ],
                  ),
                )
              : null),
    );
  }

  goToBranch(index) {
    navigationShell.goBranch(
      index,
      // initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
