import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/post_model.dart';
import 'package:classroom_app/provider/comment_provider.dart';
import 'package:classroom_app/provider/post_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/post_service.dart';
import 'package:classroom_app/src/widget/add_update_posts_dialog.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyPostsScreen extends StatelessWidget {
  MyPostsScreen({super.key});
  final PostService service = locator<PostService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
          title: "My Posts Management Hub",
          subtitle: "Posts management options are available here",
          leadingIconData: FontAwesomeIcons.envelopesBulk,
          actions: [
            Tooltip(
              message: "Create new\npost",
              exitDuration: Duration.zero,
              textAlign: TextAlign.center,
              child: IconButton(
                  onPressed: () {
                    showAnimatedDialog<void>(
                        barrierDismissible: false,
                        animationType: DialogTransitionType.fadeScale,
                        duration: const Duration(milliseconds: 300),
                        context: context,
                        builder: (BuildContext context) {
                          return const AddOrUpdatePostDialog();
                        });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  )),
            )
          ],
        ),
        body: Consumer<List<PostModel>?>(
          builder: (context, data, provider) {
            List<PostModel> myPosts = [];

            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (data.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("You don't any post for the moment")],
                ),
              );
            } else {
              for (var element in data) {
                if (element.createdByRef.id == context.read<UserProvider>().currentUser!.userId) {
                  myPosts.add(element);
                }
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myPosts.length,
                itemBuilder: (context, index) {
                  return customLisTileWidget(context, myPosts[index], index);
                },
              );
            }
          },
        ));
  }

  Widget customLisTileWidget(BuildContext context, PostModel post, int index) {
    return Consumer<ThemeProvider>(builder: (ctx, provider, child) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: ListTile(
              onTap: () async {
                int isSeenCount = 0;
                for (var comment in post.comments!) {
                  if (comment.isSeen == false) {
                    comment.isSeen = true;
                    isSeenCount++;
                  }
                }
                if (isSeenCount != 0) {
                  await context.read<CommentProvider>().updatePost(context, post, index);
                } else {
                  context.pushNamed(context.read<UserProvider>().currentUser!.role == "Admin" ? "adminPostPreview" : "myPostDetails", extra: index);
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              tileColor: Theme.of(ctx).cardTheme.color,
              leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                      child: Text(
                    "${index + 1}",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20),
                  ))),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      post.description,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.comments!.where((element) => element.isSeen == false).isNotEmpty)
                    Stack(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: Icon(
                            Icons.notifications,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red[900]),
                            child: Center(
                              child: Text(style: const TextStyle(color: Colors.white, fontSize: 10), "${post.comments!.where((element) => element.isSeen == false).length}"),
                            ),
                          ),
                        )
                      ],
                    )
                ],
              ),
              subtitle: Text(
                "Created at ${"${post.createdAt.toLocal()}".split(' ')[0]}",
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Themes.primaryColor, fontSize: 10),
              ),
              trailing: Wrap(
                spacing: 15,
                children: [
                  PopupMenuButton<String>(
                      tooltip: "Options",
                      onSelected: (value) {},
                      itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'Edit',
                              child: const Text('Edit'),
                              onTap: () {
                                // showAnimatedDialog<void>(
                                //     barrierDismissible: false,
                                //     animationType:
                                //         DialogTransitionType.fadeScale,
                                //     duration:
                                //         const Duration(milliseconds: 300),
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AddOrUpdateCategoryDialog(
                                //         category: category,
                                //       );
                                //     });
                              },
                            ),
                            PopupMenuItem<String>(
                              value: 'Delete',
                              child: const Text(
                                "Delete",
                              ),
                              onTap: () async {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DialogWidget(
                                        dialogTitle: "Delete confirmation",
                                        dialogContent: "Are you sure you want to delete this post?",
                                        isConfirmDialog: true,
                                        onConfirm: () async {
                                          Navigator.pop(context);
                                          await context.read<PostProvider>().deletePost(context, post.id);
                                        });
                                  },
                                );
                              },
                            ),
                          ],
                      child: Icon(
                        FontAwesomeIcons.ellipsisVertical,
                        color: Theme.of(context).highlightColor,
                        size: 20,
                      )),
                ],
              ),
            ),
          ));
    });
  }
}
