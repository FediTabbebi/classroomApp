import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class PostListTileWidget extends StatelessWidget {
  final ClassroomModel classroom;
  final int index;
  final UserModel createdBy;

  const PostListTileWidget({required this.classroom, required this.createdBy, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (ctx, provider, child) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                tileColor: Colors.transparent,
                leading: createdBy.profilePicture.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: createdBy.profilePicture,
                        placeholder: (context, url) => Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const UnconstrainedBox(
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  )),
                            )),
                        imageBuilder: (context, imageProvider) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Image.asset(AppImages.userProfile),
                title: Text(
                  "${createdBy.firstName} ${createdBy.lastName}",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      "Created based in tunisia - ${formatDuration(classroom.createdAt)}",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(ctx).hintColor, fontSize: 12),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Ionicons.globe_outline,
                      color: Theme.of(ctx).hintColor,
                      size: 15,
                    )
                  ],
                ),
                trailing: Wrap(
                  spacing: 15,
                  children: [
                    PopupMenuButton<String>(
                        tooltip: "Options",
                        onSelected: (value) {},
                        itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'Report classroom',
                                onTap: context.read<UserProvider>().currentUser!.role!.id == "3"
                                    ? null
                                    : () async {
                                        showDialog<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DialogWidget(
                                                dialogTitle: "Delete confirmation",
                                                dialogContent: "Are you sure you want to delete this classroom?",
                                                isConfirmDialog: true,
                                                onConfirm: () async {
                                                  Navigator.pop(context);
                                                  await context.read<ClassroomProvider>().deleteClassroom(context, classroom.id);
                                                });
                                          },
                                        );
                                      },
                                child: Text(context.read<UserProvider>().currentUser!.role == "Admin" ? 'Delete classroom' : 'Report classroom'),
                              ),
                            ],
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            FontAwesomeIcons.ellipsis,
                            color: Theme.of(ctx).highlightColor,
                            size: 20,
                          ),
                        )),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
              //   child: RichReadMoreText.fromString(
              //     text: classroom.description,
              //     settings: LengthModeSettings(
              //       trimLength: 205,
              //       trimCollapsedText: 'Show More',
              //       trimExpandedText: ' Show less ',
              //       onPressReadMore: () {
              //         /// specific method to be called on press to show more
              //       },
              //       onPressReadLess: () {
              //         /// specific method to be called on press to show less
              //       },
              //       lessStyle: TextStyle(color: Theme.of(ctx).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
              //       moreStyle: TextStyle(color: Theme.of(ctx).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
              //     ),
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        context.pushNamed(context.read<UserProvider>().currentUser!.role == "Admin" ? "adminPostPreview" : "postDetails", extra: index);
                      },
                      child: Text(
                        "${classroom.comments!.length} comments",
                        style: TextStyle(fontSize: 14, color: Theme.of(ctx).hintColor),
                      ),
                    )),
              ),
              Divider(
                height: 2,
                color: Theme.of(ctx).hintColor,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(context.read<UserProvider>().currentUser!.role == "Admin" ? "adminPostPreview" : "postDetails", extra: index);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          context.read<UserProvider>().currentUser!.role == "Admin" ? FontAwesomeIcons.eye : FontAwesomeIcons.message,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(context.read<UserProvider>().currentUser!.role == "Admin" ? "View all comments" : "Comment")
                      ],
                    ),
                  ),
                ),
              )
            ],
          ));
    });
  }
}

class CustomPostListTileShimmer extends StatelessWidget {
  const CustomPostListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          tileColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).highlightColor,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                height: 10,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                height: 10,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width / 1.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width / 1.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 10,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).highlightColor,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 20,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).highlightColor,
            ),
          ),
        )
      ],
    );
  }
}
