import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/src/widget/reusable_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListtileWidget extends StatelessWidget {
  final UserModel user;
  const UserListtileWidget({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (ctx, provider, child) {
      return Material(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).cardTheme.color,
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
                    const SizedBox(height: 5),
                    Text(
                      "Member since ${"${user.createdAt.toLocal()}".split(' ')[0]}",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing section: Status and options
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.isDeleted ? "Banned" : "Active",
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: user.isDeleted ? Colors.red : Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 5),
                  menuWidget(context, user)
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
