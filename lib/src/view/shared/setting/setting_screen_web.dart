import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingScreenWeb extends StatefulWidget {
  const SettingScreenWeb({super.key});

  @override
  State<SettingScreenWeb> createState() => _SettingScreenWebState();
}

class _SettingScreenWebState extends State<SettingScreenWeb> {
  late final Timer? longPressTimer;
  bool isEnabledNotif = false;

  void startTimer() {
    longPressTimer = Timer(const Duration(seconds: 4), () {
      context.goNamed('developerInfo');
    });
  }

  void stopTimer() {
    longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "Adjust App Settings",
          subtitle: "Customize your app settings here",
          leadingIconData: FontAwesomeIcons.gear,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            context.watch<UserProvider>().currentUser!.profilePicture.isEmpty
                ? ClipOval(
                    child: Image.asset(
                      AppImages.userProfile,
                      height: ResponsiveWidget.isLargeScreen(context) ? 220 : 150,
                      width: ResponsiveWidget.isLargeScreen(context) ? 220 : 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: context.watch<UserProvider>().currentUser!.profilePicture,
                    imageBuilder: (context, imageProvider) => Container(
                      height: ResponsiveWidget.isLargeScreen(context) ? 220 : 150,
                      width: ResponsiveWidget.isLargeScreen(context) ? 220 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => const LoadingIndicatorWidget(size: 30),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SizedBox(
                width: 500,
                child: AutoSizeText(
                  context.watch<UserProvider>().currentUser!.firstName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                context.watch<UserProvider>().currentUser!.email,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Hero(
              tag: "profileEditButton",
              child: ElevatedButtonWidget(
                  height: 50,
                  width: 400,
                  onPressed: () {
                    context.pushNamed(context.read<UserProvider>().currentUser!.role!.id == "1"
                        ? "adminProfile"
                        : context.read<UserProvider>().currentUser!.role!.id == "2"
                            ? "instructorEditProfile"
                            : "userEditProfile");
                  },
                  text: "Edit"),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(), // Enable scrolling even if content is smaller
                //overScrollColor: Colors.transparent,
                children: [
                  SwitchListTile(
                    dense: true,
                    activeColor: Themes.primaryColor,
                    title: const Text(
                      'Dark Mode',
                    ),
                    value: context.read<ThemeProvider>().isDarkMode,
                    onChanged: (value) async {
                      await context.read<ThemeProvider>().toggleTheme();
                    },
                    subtitle: Text(
                      context.watch<ThemeProvider>().isDarkMode ? "Tap to change to dark mode" : "Tap to change to light mode",
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    activeColor: Themes.primaryColor,
                    title: const Text(
                      'Notification',
                    ),
                    value: isEnabledNotif,
                    onChanged: (value) async {
                      setState(() {
                        isEnabledNotif = !isEnabledNotif;
                      });
                    },
                    subtitle: Text(
                      isEnabledNotif ? "Tap to enable app notification" : "Tap to disable app notification",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  listTileWidget("Language", "Tap to select app language", const Icon(Icons.arrow_forward_ios), () {}, context),
                  listTileWidget("Delete Account", "Tap here to delete your account", const Icon(Icons.arrow_forward_ios), () {}, context),
                  GestureDetector(
                    onLongPress: () => startTimer(),
                    onLongPressEnd: (_) => stopTimer(),
                    child: listTileWidget("About", "Tap here a learn more about our app", const Icon(Icons.arrow_forward_ios), () {}, context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget listTileWidget(String title, String subtitle, Icon? icon, VoidCallback onPressed, BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle()),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: AppColors.darkGrey,
        ),
      ),
      trailing: icon,
      onTap: () {
        onPressed();
      },
    );
  }
}
