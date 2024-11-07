import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_icons.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/provider/login_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SideBarWidget extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const SideBarWidget({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final controller = SideMenuController();

    const List<NavItemModel> menuItems = [
      NavItemModel(name: 'Dashboard', icon: FontAwesomeIcons.sheetPlastic),
    ];
    const List<NavItemModel> accountItems = [
      NavItemModel(name: 'Settings', icon: FontAwesomeIcons.gear),
    ];

    return Row(
      children: [
        SideMenu(
          backgroundColor: context.watch<ThemeProvider>().isDarkMode ? const Color(0xff201D22) : Colors.white,
          hasResizer: false,
          hasResizerToggle: false,
          maxWidth: 300,
          minWidth: 67,
          position: SideMenuPosition.left,
          controller: controller,
          builder: (data) {
            return SideMenuData(
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hedearWidget(data, context),
                    if (data.isOpen)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: SizedBox(
                          height: 38,
                          child: TextFormField(
                            cursorHeight: 17.5,
                            style: const TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(width: 0.1, color: Themes.primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(width: 0.1, color: Color(0xffD3D7DB)), borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                                hintText: "Search",
                                hintStyle: const TextStyle(fontSize: 14, height: 3.5)),
                          ),
                        ),
                      ),
                    if (data.isOpen)
                      const Padding(
                        padding: EdgeInsets.only(left: 10, top: 30, bottom: 15),
                        child: Text(
                          "Menu",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                  ],
                ),
                items: [
                  ...menuItems.map(
                    (e) => SideMenuItemDataTile(
                      isSelected: navigationShell.currentIndex == menuItems.indexOf(e),
                      onTap: () => goToBranch(menuItems.indexOf(e)),
                      title: e.name,
                      icon: Icon(
                        e.icon,
                        size: 20,
                      ),
                      hasSelectedLine: true,
                      borderRadius: BorderRadius.zero,
                      margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
                      itemHeight: 42,
                      highlightSelectedColor: Colors.transparent,
                      hoverColor: context.watch<ThemeProvider>().isDarkMode ? const Color(0xff18161A) : const Color(0xffF3F3F3),
                      selectedLineSize: const Size(5, 60),
                      titleStyle: const TextStyle(fontSize: 16),
                      selectedIcon: Icon(
                        e.icon,
                        size: 20,
                        color: Themes.primaryColor,
                      ),
                      selectedTitleStyle: const TextStyle(fontSize: 16, color: Themes.primaryColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (data.isOpen) const SideMenuItemDataDivider(divider: Divider(), padding: EdgeInsetsDirectional.only(top: 15)),
                  if (data.isOpen) const SideMenuItemDataTitle(title: 'Account', padding: EdgeInsetsDirectional.only(start: 10, top: 20, bottom: 15)),
                  ...accountItems.map(
                    (e) => SideMenuItemDataTile(
                      isSelected: navigationShell.currentIndex == accountItems.indexOf(e) + 3,
                      onTap: () {
                        goToBranch(accountItems.indexOf(e) + 3);
                      },
                      title: e.name,
                      icon: Icon(
                        e.icon,
                        size: 20,
                      ),
                      hasSelectedLine: true,
                      borderRadius: BorderRadius.zero,
                      margin: const EdgeInsetsDirectional.symmetric(
                        vertical: 5,
                      ),
                      itemHeight: 42,
                      highlightSelectedColor: Colors.transparent,
                      hoverColor: context.watch<ThemeProvider>().isDarkMode ? const Color(0xff18161A) : const Color(0xffF3F3F3),
                      selectedLineSize: const Size(5, 60),
                      titleStyle: const TextStyle(fontSize: 16),
                      selectedIcon: Icon(
                        e.icon,
                        size: 20,
                        color: Themes.primaryColor,
                      ),
                      selectedTitleStyle: const TextStyle(fontSize: 16, color: Themes.primaryColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SideMenuItemDataTile(
                    isSelected: navigationShell.currentIndex == 10,
                    onTap: () {
                      dialogBuilder(context);
                    },
                    title: "Logout",
                    icon: const Icon(
                      FontAwesomeIcons.rightFromBracket,
                      size: 20,
                    ),
                    borderRadius: BorderRadius.zero,
                    margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
                    itemHeight: 42,
                    highlightSelectedColor: Colors.transparent,
                    hoverColor: context.watch<ThemeProvider>().isDarkMode ? const Color(0xff18161A) : const Color(0xffF3F3F3),
                    selectedLineSize: const Size(5, 60),
                    titleStyle: const TextStyle(fontSize: 16),
                    selectedTitleStyle: const TextStyle(fontSize: 16, color: Themes.primaryColor, fontWeight: FontWeight.w700),
                  ),
                ],
                footer: footerWidget(data, context));
          },
        ),
        Expanded(child: navigationShell)
      ],
    );
  }

  Widget hedearWidget(dynamic data, BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: data.minWidth,
              height: double.maxFinite,
              child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Image.asset(
                    AppIcons.appLogo,
                    height: 30,
                    width: 30,
                  )),
            ),
            if (data.isOpen)
              const Expanded(
                child: AutoSizeText(
                  'ClassConnect',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget footerWidget(
    dynamic data,
    BuildContext context,
  ) {
    return Container(
      height: 60,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: data.minWidth,
              height: double.maxFinite,
              child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Center(
                    child: context.watch<UserProvider>().currentUser!.profilePicture.isEmpty
                        ? ClipOval(
                            child: Image.asset(
                              AppImages.userProfile,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: context.watch<UserProvider>().currentUser!.profilePicture,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => const LoadingIndicatorWidget(
                              size: 30,
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                  )),
            ),
            if (data.isOpen)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      context.watch<UserProvider>().currentUser!.firstName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    AutoSizeText(
                      context.watch<UserProvider>().currentUser!.email,
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void goToBranch(index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogWidget(
          dialogTitle: "Logout confirmation",
          dialogContent: "Are you sure you want to logout?",
          isConfirmDialog: true,
          onConfirm: () => context.read<LoginProvider>().signoutUser(),
        );
      },
    );
  }
}

class NavItemModel {
  const NavItemModel({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}
