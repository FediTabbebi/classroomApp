import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/provider/login_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserSettingsScreen extends StatelessWidget {
  UserSettingsScreen({super.key});
  final AuthenticationServices authService = locator<AuthenticationServices>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: const AppBarWidget(title: "Setting hub", subtitle: "Edit and manage all your settings here", leadingIconData: FontAwesomeIcons.gear),
          body: Column(children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Center(
                child: SizedBox(
                  height: 180,
                  child: Card(
                      elevation: 2,
                      child: Column(children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            "Profile",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          )
                          //  Text("Profile",style:TextStyle(color: Colors.white,fontSize: 26)
                          // style:Theme.of(context).textTheme.bodyText1
                          //  ),
                        ]),
                        // SizedBox(height: 10.h),
                        Row(
                          children: [
                            const SizedBox(width: 30),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: context.watch<UserProvider>().currentUser!.profilePicture.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: context.read<UserProvider>().currentUser!.profilePicture,
                                        imageBuilder: (context, imageProvider) => Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : Image.asset(
                                        AppImages.userProfile,
                                        scale: 15,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(children: [
                                  SizedBox(
                                    width: 150,
                                    child: RichText(
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        text: context.read<UserProvider>().currentUser!.firstName,
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: "  ${context.read<UserProvider>().currentUser!.lastName} ",
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                              )),
                                        ],
                                      ),
                                    ),
                                  )
                                ]),

                                // Text(currentUser!.phoneNumber,style:TextStyle(color: Colors.grey,fontSize: 16),),
                              ],
                            ),
                          ],
                        ),
                      ])),
                ),
              ),
            ),

            //Setting Card
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "Settings",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                        ]),
                        const SizedBox(height: 20),
                        SettingsItem(
                            name: 'Edit my profile',
                            icon: const Icon(
                              FontAwesomeIcons.user,
                              size: 20.0,
                            ),
                            onPressed: () => onItemPressed(context, index: 0)),
                        SettingsItem(
                            name: 'Privacy and safety',
                            icon: const Icon(
                              Icons.lock_outline,
                              size: 25.0,
                            ),
                            onPressed: () => onItemPressed(context, index: 1)),
                        SettingsItem(
                            name: 'Language',
                            icon: const Icon(
                              Icons.language,
                              size: 25.0,
                            ),

                            // RadiantGradientMask(child:  Icon(Icons.language,)
                            //),
                            onPressed: () => onItemPressed(context, index: 2)),
                        darkMode(context),
                        SettingsItem(
                            name: 'Log out',
                            icon: const Icon(
                              Icons.logout,
                              size: 25.0,
                            ),
                            endingIcon: FontAwesomeIcons.angleRight,
                            onPressed: () => onItemPressed(context, index: 3)),
                      ],
                    ),
                  )),
            ),

            const SizedBox(height: 40),
          ])),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    switch (index) {
      case 0:
        context.goNamed(context.read<UserProvider>().currentUser!.role == "Admin" ? "adminProfile" : "userEditProfile");
        break;
      case 1:
        //  Get.to(() =>  const Privacy(), transition: Transition.circularReveal);
        break;
      case 2:
        //  Get.to(() =>  const Language(), transition: Transition.circularReveal);
        break;
      case 3:
        dialogBuilder(context);
        break;
    }
  }

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogWidget(
          dialogTitle: "Logout confirmation",
          dialogContent: "Are you sure you want to logout?",
          isConfirmDialog: true,
          onConfirm: () async => await context.read<LoginProvider>().signoutUser(),
        );
      },
    );
  }

  //switch button for dark mode
  Widget buildSwitch(BuildContext context) => Transform.scale(
        scale: 0.7,
        child: Switch(value: context.read<ThemeProvider>().isDarkMode, onChanged: (value) => context.read<ThemeProvider>().toggleTheme(), activeColor: Theme.of(context).colorScheme.primary),
      );

  // dark mode row (bc leading icon is a widget)
  Widget darkMode(BuildContext context) => SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 20),
            const SizedBox(
              width: 40,
              child: Icon(
                FontAwesomeIcons.moon,
                size: 25.0,
              ),
            ),
            const SizedBox(width: 20),
            const Text("Dark Mode"),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildSwitch(context),
                const SizedBox(width: 10),
              ],
            ))
          ],
        ),
      );
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key, required this.name, required this.icon, this.endingIcon = FontAwesomeIcons.angleRight, required this.onPressed});

  final String name;
  final Widget icon;
  final IconData endingIcon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: onPressed,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: 40,
              child: icon,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              name,
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(
                    endingIcon,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
