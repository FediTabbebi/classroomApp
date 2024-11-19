import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CommentHeaderWidget extends StatelessWidget {
  final ClassroomModel classroom;

  final UserModel createdBy;

  const CommentHeaderWidget({required this.classroom, required this.createdBy, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (ctx, provider, child) {
      return FlexibleSpaceBar(
        expandedTitleScale: 1,
        titlePadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      context.pop();
                      // context.read<CommentProvider>().postCommentController.clear();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                    )),
                createdBy.profilePicture.isNotEmpty
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: CachedNetworkImage(
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
                        ),
                      )
                    : Image.asset(AppImages.userProfile),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${createdBy.firstName} ${createdBy.lastName}",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatDuration(classroom.createdAt),
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
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
