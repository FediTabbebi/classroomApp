// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:classroom_app/constant/app_images.dart';
// import 'package:classroom_app/model/user_model.dart';
// import 'package:classroom_app/provider/theme_provider.dart';
// import 'package:classroom_app/provider/update_user_provider.dart';
// import 'package:classroom_app/provider/user_provider.dart';
// import 'package:classroom_app/src/widget/add_update_user_dialog.dart';
// import 'package:classroom_app/src/widget/app_bar_widget.dart';
// import 'package:classroom_app/src/widget/user_management_shimmer_widget.dart';
// import 'package:classroom_app/theme/themes.dart';
// import 'package:classroom_app/utils/responsive_helper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';

// class AdminUserManagementScreen extends StatefulWidget {
//   final UserProvider provider;
//   final List<UserModel>? usersList;
//   const AdminUserManagementScreen({required this.provider, required this.usersList, super.key});

//   @override
//   State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
// }

// class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
//   late final FocusNode textFieldFocusNode;
//   @override
//   void initState() {
//     textFieldFocusNode = FocusNode();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     textFieldFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => textFieldFocusNode.unfocus(),
//       child: Scaffold(
//         appBar: AppBarWidget(
//           title: "User Management Hub",
//           subtitle: "User management options are available here",
//           leadingIconData: FontAwesomeIcons.userGroup,
//           actions: [
//             Tooltip(
//               message: "Add user",
//               exitDuration: Duration.zero,
//               child: IconButton(
//                   onPressed: () {
//                     showAnimatedDialog<void>(
//                         barrierDismissible: false,
//                         animationType: DialogTransitionType.fadeScale,
//                         duration: const Duration(milliseconds: 300),
//                         context: context,
//                         builder: (BuildContext context) {
//                           return const AddOrUpdateUserDialog();
//                         });
//                   },
//                   icon: Icon(
//                     Icons.add,
//                     color: Theme.of(context).colorScheme.primary,
//                     size: 30,
//                   )),
//             )
//           ],
//         ),
//         body: ListView(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
//               child: SizedBox(
//                 height: 50,
//                 child: TextField(
//                   focusNode: textFieldFocusNode,
//                   onChanged: (value) {
//                     //  timer?.cancel();
//                     context.read<UserProvider>().filterData(value.trim());
//                   },
//                   decoration: const InputDecoration(isDense: true, prefixIcon: Icon(Icons.search), label: Text("Search")),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 40,
//             ),
//             widget.usersList == null
//                 ? const AdminUserManagementShimmer()
//                 : widget.provider.userModelList!.isEmpty
//                     ? const Center(
//                         child: Text(" There is no user matching this name"),
//                       )
//                     : widget.usersList == null
//                         ? const AdminUserManagementShimmer()
//                         : Selector<UserProvider, Map<String, dynamic>>(
//                             selector: (context, provider) {
//                               bool isLoading = provider.userModelList!.isEmpty;

//                               List<TableRow> userRows = List.generate(provider.userModelList!.length, (index) {
//                                 return TableRow(
//                                   children: getTableCells(provider.userModelList![index], context, index * 100),
//                                 );
//                               });
//                               return {'isLoading': isLoading, 'userRows': userRows};
//                             },
//                             builder: (context, data, _) {
//                               bool isLoading = data['isLoading'];
//                               List<TableRow> userRows = data['userRows'];

//                               return Center(
//                                 child: Table(
//                                   border: TableBorder(
//                                     horizontalInside: BorderSide(
//                                       width: 0.5,
//                                       color: Theme.of(context).highlightColor,
//                                     ),
//                                   ),
//                                   columnWidths: ResponsiveWidget.isLargeScreen(context)
//                                       ? {
//                                           0: FixedColumnWidth(MediaQuery.of(context).size.width / 3),
//                                           1: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
//                                           2: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
//                                           3: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
//                                           4: FixedColumnWidth(MediaQuery.of(context).size.width / 8),
//                                         }
//                                       : kIsWeb
//                                           ? {
//                                               0: FixedColumnWidth(MediaQuery.of(context).size.width / 1.3),
//                                             }
//                                           : ResponsiveWidget.isMediumScreen(context)
//                                               ? {
//                                                   0: FixedColumnWidth(MediaQuery.of(context).size.width / 1.5),
//                                                 }
//                                               : {
//                                                   0: FixedColumnWidth(MediaQuery.of(context).size.width),
//                                                 },
//                                   children: getTableRows(userRows, context),
//                                 ),
//                               );
//                             },
//                           ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget tableHeaderRow(String title, bool end, bool middle, BuildContext context) {
//     return TableCell(
//         child: Text(title,
//             textAlign: middle
//                 ? TextAlign.center
//                 : end
//                     ? TextAlign.end
//                     : TextAlign.start));
//   }

//   List<TableRow> getTableRows(List<TableRow> userRows, BuildContext context) {
//     if (ResponsiveWidget.isLargeScreen(context)) {
//       return [
//         TableRow(
//           children: [
//             tableHeaderRow("User", false, false, context),
//             tableHeaderRow("Member Since", false, false, context),
//             tableHeaderRow("Role", false, false, context),
//             tableHeaderRow("Status", true, false, context),
//             tableHeaderRow("Options", true, ResponsiveWidget.isLargeScreen(context) ? true : false, context),
//           ],
//         ),
//         ...userRows,
//       ];
//     } else {
//       return [
//         TableRow(
//           children: [
//             tableHeaderRow("", true, false, context),
//           ],
//         ),
//         ...userRows,
//       ];
//     }
//   }

//   List<TableCell> getTableCells(UserModel user, BuildContext context, int delayDuration) {
//     if (ResponsiveWidget.isLargeScreen(context)) {
//       return [
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: ListTile(
//               tileColor: Theme.of(context).scaffoldBackgroundColor,
//               contentPadding: EdgeInsets.zero,
//               leading: user.profilePicture.isEmpty
//                   ? Container(
//                       width: 60,
//                       height: 60,
//                       decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           image: DecorationImage(
//                               fit: BoxFit.cover,
//                               image: AssetImage(
//                                 AppImages.userProfile,
//                               ))),
//                     )
//                   : CachedNetworkImage(
//                       imageUrl: user.profilePicture,
//                       placeholder: (context, url) => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
//                       imageBuilder: (context, imageProvider) => Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => const Icon(Icons.error),
//                     ),
//               title: Tooltip(
//                 showDuration: const Duration(milliseconds: 0),
//                 message: user.firstName,
//                 child: Text(
//                   user.firstName,
//                   softWrap: true,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               subtitle: Tooltip(
//                 showDuration: const Duration(milliseconds: 0),
//                 message: user.email,
//                 child: Text(
//                   user.email,
//                   softWrap: true,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ),
//             ).animate().flip(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, delay: Duration(milliseconds: delayDuration))),
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: Text(
//               "${user.createdAt.toLocal()}".split(' ')[0],
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//             ).animate().flip(duration: const Duration(milliseconds: 250), delay: Duration(milliseconds: delayDuration))),
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: PopupMenuButton<String>(
//               tooltip: "Edit user role",
//               onSelected: (value) {},
//               itemBuilder: (context) => [
//                 const PopupMenuItem<String>(
//                   value: 'admin',
//                   child: Text('Admin'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'user',
//                   child: Text('User'),
//                 ),
//               ],
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       user.role,
//                       softWrap: true,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const Icon(Icons.arrow_drop_down),
//                 ],
//               ),
//             ).animate().flip(duration: const Duration(milliseconds: 350), delay: Duration(milliseconds: delayDuration))),
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: Text(
//               user.isDeleted ? " Deleted" : "Active",
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.end,
//               style: TextStyle(
//                 color: user.isDeleted ? Colors.red : Colors.green,
//               ),
//             ).animate().flip(duration: const Duration(milliseconds: 350), delay: Duration(milliseconds: delayDuration))),
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Tooltip(
//                   showDuration: const Duration(milliseconds: 0),
//                   message: "Edit",
//                   child: IconButton(
//                     splashRadius: 15,
//                     icon: const Icon(
//                       FontAwesomeIcons.pen,
//                       size: 15,
//                     ),
//                     onPressed: () {},
//                   ),
//                 ).animate().flip(duration: const Duration(milliseconds: 350), delay: Duration(milliseconds: delayDuration)),
//                 Tooltip(
//                   showDuration: const Duration(milliseconds: 0),
//                   message: user.isDeleted ? "Restore" : "Delete",
//                   child: IconButton(
//                     splashRadius: 15,
//                     icon: Icon(
//                       user.isDeleted ? FontAwesomeIcons.trashCanArrowUp : FontAwesomeIcons.trash,
//                       color: user.isDeleted ? const Color(0xff0A2342) : Colors.red,
//                       size: 15,
//                     ),
//                     onPressed: () {},
//                   ),
//                 ).animate().flip(duration: const Duration(milliseconds: 350), delay: Duration(milliseconds: delayDuration)),
//               ],
//             ))
//       ];
//     } else {
//       return [
//         TableCell(
//             verticalAlignment: TableCellVerticalAlignment.middle,
//             child: Padding(
//                 padding: const EdgeInsets.only(top: 5.0, bottom: 5),
//                 child: ListTile(
//                   tileColor: Theme.of(context).scaffoldBackgroundColor,
//                   leading: user.profilePicture.isEmpty
//                       ? Container(
//                           width: 60,
//                           height: 60,
//                           decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               image: DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: AssetImage(
//                                     AppImages.userProfile,
//                                   ))),
//                         )
//                       : CachedNetworkImage(
//                           imageUrl: user.profilePicture,
//                           placeholder: (context, url) => Container(
//                               height: 20,
//                               width: 20,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const CircularProgressIndicator()),
//                           imageBuilder: (context, imageProvider) => Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => const Icon(Icons.error),
//                         ),
//                   title: Text(
//                     user.firstName,
//                     softWrap: true,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.email,
//                         softWrap: true,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         "Member since ${"${user.createdAt.toLocal()}".split(' ')[0]}",
//                         softWrap: true,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(color: Themes.primaryColor, fontSize: 10),
//                       ),
//                     ],
//                   ),
//                   trailing: Wrap(
//                     spacing: 15,
//                     children: [
//                       Text(
//                         user.isDeleted ? " Deleted" : "Active",
//                         softWrap: true,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.end,
//                         style: TextStyle(color: user.isDeleted ? Colors.red : Colors.green, fontSize: 14),
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       PopupMenuButton<String>(
//                           tooltip: "Options",
//                           onSelected: (value) {},
//                           itemBuilder: (context) => [
//                                 const PopupMenuItem<String>(
//                                   value: 'Edit',
//                                   child: Text('Edit'),
//                                 ),
//                                 const PopupMenuItem<String>(
//                                   value: 'Delete',
//                                   child: Text('Delete'),
//                                 ),
//                               ],
//                           child: Icon(
//                             FontAwesomeIcons.ellipsisVertical,
//                             color: Theme.of(context).highlightColor,
//                             size: 20,
//                           )),
//                     ],
//                   ),
//                 ).animate().slideX(duration: const Duration(milliseconds: 550), begin: -1, end: 0, curve: Curves.easeInOut, delay: Duration(milliseconds: delayDuration))))
//       ];
//     }
//   }
// }

// Widget customLisTileWidget(BuildContext context, UserModel user, int durationDelay) => Consumer<ThemeProvider>(builder: (ctx, provider, child) {
//       return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Material(
//             elevation: 1,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//             child: ListTile(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//               tileColor: Theme.of(ctx).cardTheme.color,
//               leading: user.profilePicture.isEmpty
//                   ? const SizedBox(
//                       width: 60,
//                       height: 60,
//                       child: Icon(
//                         Icons.person,
//                         size: 35,
//                       ),
//                     )
//                   : SizedBox(
//                       width: 60,
//                       height: 60,
//                       child: CachedNetworkImage(
//                         imageUrl: user.profilePicture,
//                         placeholder: (context, url) => Container(
//                             height: 20,
//                             width: 20,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                             ),
//                             child: const UnconstrainedBox(
//                               child: SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                   )),
//                             )),
//                         imageBuilder: (context, imageProvider) => Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => const Icon(Icons.error),
//                       ),
//                     ),
//               title: Text(
//                 user.firstName,
//                 softWrap: true,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     user.email,
//                     softWrap: true,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     "Member since ${"${user.createdAt.toLocal()}".split(' ')[0]}",
//                     softWrap: true,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(color: Themes.primaryColor, fontSize: 10),
//                   ),
//                 ],
//               ),
//               trailing: Wrap(
//                 spacing: 15,
//                 children: [
//                   Text(
//                     user.isDeleted ? " Banned" : "Active",
//                     softWrap: true,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.end,
//                     style: TextStyle(color: user.isDeleted ? Colors.red : Colors.green, fontSize: 14),
//                   ),
//                   const SizedBox(
//                     width: 5,
//                   ),
//                   PopupMenuButton<String>(
//                       tooltip: "Options",
//                       onSelected: (value) {},
//                       itemBuilder: (context) => [
//                             PopupMenuItem<String>(
//                               value: 'Edit',
//                               child: const Text('Edit'),
//                               onTap: () {
//                                 showAnimatedDialog<void>(
//                                     barrierDismissible: false,
//                                     animationType: DialogTransitionType.fadeScale,
//                                     duration: const Duration(milliseconds: 300),
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AddOrUpdateUserDialog(
//                                         user: user,
//                                       );
//                                     });
//                               },
//                             ),
//                             PopupMenuItem<String>(
//                               value: 'Ban',
//                               child: Text(
//                                 user.isDeleted ? " Unban" : "ban",
//                               ),
//                               onTap: () async {
//                                 await context.read<UpdateUserProvider>().banOrUnbanUser(context, user);
//                               },
//                             ),
//                           ],
//                       child: Icon(
//                         FontAwesomeIcons.ellipsisVertical,
//                         color: Theme.of(context).highlightColor,
//                         size: 20,
//                       )),
//                 ],
//               ),
//             ),
//           )

//           // .animate().slideX(
//           //     duration: const Duration(milliseconds: 550),
//           //     begin: -1,
//           //     end: 0,
//           //     curve: Curves.easeInOut,
//           //     delay: Duration(milliseconds: durationDelay)),
//           );
//     });
