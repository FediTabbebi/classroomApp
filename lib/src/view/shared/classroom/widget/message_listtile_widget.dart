import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/remotes/message_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageListTileWidget extends StatelessWidget {
  final MessageModel message;
  final UserModel? sender;
  const MessageListTileWidget({required this.message, required this.sender, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (ctx, themProvider, child) {
      return Skeletonizer(
        enabled: sender == null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sender?.profilePicture == null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipOval(child: Container(color: Theme.of(context).cardTheme.color, width: 35, height: 35, child: Image.asset(AppImages.userProfile))),
                    )
                  : sender!.profilePicture.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: CachedNetworkImage(
                              imageUrl: sender!.profilePicture,
                              placeholder: (context, url) => Container(
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  child: const UnconstrainedBox(
                                    child: SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: LoadingIndicatorWidget(
                                          size: 25,
                                        )),
                                  )),
                              imageBuilder: (context, imageProvider) => Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardTheme.color,
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipOval(child: Container(color: Theme.of(context).cardTheme.color, width: 35, height: 35, child: Image.asset(AppImages.userProfile))),
                        ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${sender?.firstName} ${sender?.lastName}",
                          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            formatDuration(message.createdAt),
                            style: TextStyle(color: Theme.of(ctx).hintColor, fontWeight: FontWeight.w300, fontSize: 10),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      message.description,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
