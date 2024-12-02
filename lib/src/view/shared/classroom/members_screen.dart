import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  final ClassroomModel classroom;
  const MembersScreen({required this.classroom, super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.classroom.invitedUsers!.isEmpty
        ? const Center(
            child: Text("This classroom has no members"),
          )
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            controller: _scrollController,
            itemCount: widget.classroom.invitedUsers!.length,
            itemBuilder: (context, index) {
              final user = widget.classroom.invitedUsers![index];

              return userListitle(context, user);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            },
          );
  }

  Widget userListitle(BuildContext context, UserModel user) {
    return Material(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading section: User Profile Picture
            user.profilePicture.isEmpty
                ? Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.read<ThemeProvider>().isDarkMode ? const Color.fromARGB(255, 25, 25, 30) : Themes.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: Image.asset(AppImages.userProfile).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 80,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: user.profilePicture,
                      placeholder: (context, url) => const SizedBox(
                        height: 20,
                        width: 20,
                        child: UnconstrainedBox(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingIndicatorWidget(
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
            const SizedBox(width: 16), // Spacing between leading and text

            // Main content: User details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (User first name)
                  Text(
                    "${user.firstName} ${user.lastName}",
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Subtitle: User email and "Member since" info
                  Text(
                    user.email,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
            ),

            if (context.read<UserProvider>().currentUser!.role!.id == "1" || widget.classroom.createdBy!.userId == context.read<UserProvider>().currentUser!.role!.id)
              MenuAnchor(
                  alignmentOffset: const Offset(-150, -30),
                  builder: (BuildContext context, MenuController controller, Widget? child) {
                    return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(
                          FontAwesomeIcons.ellipsisVertical,
                          size: 24,
                        ),
                        tooltip: "Options");
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () async {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext ctx) {
                            return DialogWidget(
                              dialogTitle: "Remove Confirmation",
                              dialogContent: "Are you sure you want to remove this user from classroom?",
                              isConfirmDialog: true,
                              onConfirm: () async {
                                Navigator.pop(ctx);

                                await context.read<ClassroomProvider>().deleteInvitedUserFromClassroom(context, widget.classroom, user.userId);

                                //  await context.read<UpdateUserProvider>().banOrUnbanUser(context, user, user.role!.id);
                              },
                            );
                          },
                        );
                      },
                      leadingIcon: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.red,
                            size: 20,
                          )),
                      child: const SizedBox(
                        width: 100,
                        child: Text(
                          "Remove",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ])
          ],
        ),
      ),
    );
  }
}
