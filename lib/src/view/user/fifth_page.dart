// import 'package:classroom_app/constant/app_images.dart';
// import 'package:classroom_app/locator.dart';
// import 'package:classroom_app/provider/theme_provider.dart';
// import 'package:classroom_app/provider/user_provider.dart';
// import 'package:classroom_app/service/auth_service.dart';
// import 'package:classroom_app/src/widget/app_bar_widget.dart';
// import 'package:classroom_app/src/widget/dialog_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';

// class FifthPage extends StatelessWidget {
//   FifthPage({super.key});
//   final AuthenticationServices authService = locator<AuthenticationServices>();
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: const AppBarWidget(
//               title: "Setting hub",
//               subtitle: "Edit and manage all your settings here",
//               leadingIconData: FontAwesomeIcons.user),
//           body: Column(children: [
//             const SizedBox(height: 30),
//             Padding(
//               padding: const EdgeInsets.only(left: 20.0, right: 20),
//               child: Center(
//                 child: SizedBox(
//                   height: 180,
//                   child: Card(
//                       elevation: 2,
//                       child: InkWell(
//                         onTap: () {
//                           //  Get.to(()=>const Profile(),

//                           //  transition: Transition.circularReveal
//                           //      );
//                         },
//                         borderRadius: BorderRadius.circular(15),
//                         child: Column(children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           const Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "Profile",
//                                   style: TextStyle(
//                                       fontSize: 26,
//                                       fontWeight: FontWeight.bold),
//                                 )
//                                 //  Text("Profile",style:TextStyle(color: Colors.white,fontSize: 26)
//                                 // style:Theme.of(context).textTheme.bodyText1
//                                 //  ),
//                               ]),
//                           // SizedBox(height: 10.h),
//                           Row(
//                             children: [
//                               const SizedBox(width: 30),
//                               SizedBox(
//                                 child: Image.asset(
//                                   AppImages.userProfile,
//                                   scale: 15,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Column(
//                                 children: [
//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                           context
//                                               .read<UserProvider>()
//                                               .currentUser!
//                                               .firstName,
//                                           style: const TextStyle(fontSize: 22)),
//                                       const SizedBox(
//                                         width: 2,
//                                       ),
//                                       Text(
//                                           context
//                                               .read<UserProvider>()
//                                               .currentUser!
//                                               .lastName,
//                                           style: const TextStyle(fontSize: 22)),
//                                     ],
//                                   ),

//                                   // Text(currentUser!.phoneNumber,style:TextStyle(color: Colors.grey,fontSize: 16),),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ]),
//                       )),
//                 ),
//               ),
//             ),

//             //Setting Card
//             Expanded(
//               child: Padding(
//                   padding:
//                       const EdgeInsets.only(left: 20.0, right: 20, top: 20),
//                   child: Card(
//                     elevation: 2,
//                     child: Container(
//                       //             decoration: BoxDecoration(
//                       //                   borderRadius: BorderRadius.circular(15),
//                       // gradient:isDarkMode?   LinearGradient(colors: <Color>[Colors.black,Colors.black]):LinearGradient(colors: <Color>[ Color.fromARGB(30, 33, 149, 243),Color.fromARGB(30, 155, 39, 176),],begin: Alignment.topCenter,end: Alignment.bottomCenter,)),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 20),
//                           const Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                     padding: EdgeInsets.only(left: 20),
//                                     child: Text(
//                                       "Settings",
//                                       style: TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold),
//                                     )),
//                               ]),
//                           const SizedBox(height: 20),
//                           SettingsItem(
//                               name: 'Manage my account',
//                               icon: const Icon(
//                                 FontAwesomeIcons.user,
//                                 size: 25.0,
//                               ),
//                               onPressed: () =>
//                                   onItemPressed(context, index: 0)),
//                           SettingsItem(
//                               name: 'Privacy and safety',
//                               icon: const Icon(
//                                 Icons.lock_outline_rounded,
//                                 size: 25.0,
//                               ),
//                               onPressed: () =>
//                                   onItemPressed(context, index: 1)),
//                           SettingsItem(
//                               name: 'Language',
//                               icon: const Icon(
//                                 Icons.language,
//                                 size: 25.0,
//                               ),

//                               // RadiantGradientMask(child:  Icon(Icons.language,)
//                               //),
//                               onPressed: () =>
//                                   onItemPressed(context, index: 2)),
//                           darkMode(context),
//                           SettingsItem(
//                               name: 'Log out',
//                               icon: const Icon(
//                                 Icons.logout,
//                                 size: 25.0,
//                               ),
//                               endingIcon: FontAwesomeIcons.angleRight,
//                               onPressed: () =>
//                                   onItemPressed(context, index: 3)),
//                         ],
//                       ),
//                     ),
//                   )),
//             ),

//             const SizedBox(height: 40),
//           ])),
//     );
//   }

//   void onItemPressed(BuildContext context, {required int index}) {
//     switch (index) {
//       case 0:
//         //  Get.to(() =>  const MangeMyAccount() ,transition: Transition.circularReveal);
//         break;
//       case 1:
//         //  Get.to(() =>  const Privacy(), transition: Transition.circularReveal);
//         break;
//       case 2:
//         //  Get.to(() =>  const Language(), transition: Transition.circularReveal);
//         break;
//       case 3:
//         dialogBuilder(context);
//         break;
//     }
//   }

//   Future<void> dialogBuilder(BuildContext context) {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return DialogWidget(
//           dialogTitle: "Logout confirmation",
//           dialogContent: "Are you sure you want to logout?",
//           isConfirmDialog: true,
//           onConfirm: () async => await authService.signOut(),
//         );
//       },
//     );
//   }

//   //switch button for dark mode
//   Widget buildSwitch(BuildContext context) => Transform.scale(
//         scale: 0.7,
//         child: Switch(
//             value: context.read<ThemeProvider>().isDarkMode,
//             onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
//             activeColor: Theme.of(context).colorScheme.primary),
//       );

//   // dark mode row (bc leading icon is a widget)
//   Widget darkMode(BuildContext context) => SizedBox(
//         height: 55,
//         child: Row(
//           children: [
//             const SizedBox(width: 20),
//             const Icon(
//               FontAwesomeIcons.moon,
//               size: 25.0,
//             ),
//             const SizedBox(width: 22),
//             const Text("Dark Mode"),
//             Expanded(
//                 child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 buildSwitch(context),
//                 const SizedBox(width: 10),
//               ],
//             ))
//           ],
//         ),
//       );
// }

// class SettingsItem extends StatefulWidget {
//   const SettingsItem(
//       {Key? key,
//       required this.name,
//       required this.icon,
//       this.endingIcon = (FontAwesomeIcons.angleRight),
//       required this.onPressed})
//       : super(key: key);

//   final String name;
//   final Widget icon;
//   final IconData endingIcon;
//   final Function() onPressed;

//   @override
//   State<SettingsItem> createState() => _SettingsItemState();
// }

// class _SettingsItemState extends State<SettingsItem> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       hoverColor: Colors.transparent,
//       onTap: widget.onPressed,
//       child: SizedBox(
//         height: 60,
//         child: Row(
//           children: [
//             const SizedBox(width: 20),
//             widget.icon,
//             const SizedBox(
//               width: 20,
//             ),
//             Text(
//               widget.name,
//             ),
//             Expanded(
//                 child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Icon(
//                   widget.endingIcon,
//                   size: 25.0,
//                 ),
//                 const SizedBox(width: 10),
//               ],
//             ))
//           ],
//         ),
//       ),
//     );
//   }
// }
