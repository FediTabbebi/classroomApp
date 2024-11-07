import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/src/view/shared/sidebar_widget.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserHomeMain extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const UserHomeMain({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: !context.read<AppService>().isMobileDevice
              ? SideBarWidget(
                  navigationShell: navigationShell,
                )
              : Expanded(child: navigationShell),
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
                        icon: const Icon(Icons.dashboard),
                        title: const Text('Home'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(FontAwesomeIcons.usps),
                        title: const Text('All posts'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(FontAwesomeIcons.envelopesBulk),
                        title: const Text('My posts'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.calendar_today),
                        title: const Text('Calendar'),
                      ),
                      FlashyTabBarItem(
                        activeColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.settings),
                        title: const Text('settings'),
                      ),
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
