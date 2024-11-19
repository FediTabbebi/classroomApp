import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/comment_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentListTileWidget extends StatelessWidget {
  final CommentModel comment;
  final UserModel commenter;
  const CommentListTileWidget({required this.comment, required this.commenter, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (ctx, themProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commenter.profilePicture.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: CachedNetworkImage(
                        imageUrl: commenter.profilePicture,
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
                        "${commenter.firstName} ${commenter.lastName}",
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          formatDuration(comment.createdAt),
                          style: TextStyle(color: Theme.of(ctx).hintColor, fontWeight: FontWeight.w300, fontSize: 10),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    comment.description,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}




// class CommentListTileWidget extends StatelessWidget {
//   final CommentModel comment;
//   final UserModel commenter;
//   const CommentListTileWidget({required this.comment, required this.commenter, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(builder: (ctx, themProvider, child) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             commenter.profilePicture.isNotEmpty
//                 ? Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: SizedBox(
//                       height: 35,
//                       width: 35,
//                       child: CachedNetworkImage(
//                         imageUrl: commenter.profilePicture,
//                         placeholder: (context, url) => Container(
//                             height: 35,
//                             width: 35,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                             ),
//                             child: const UnconstrainedBox(
//                               child: SizedBox(
//                                   height: 25,
//                                   width: 25,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   )),
//                             )),
//                         imageBuilder: (context, imageProvider) => Container(
//                           width: 35,
//                           height: 35,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => const Icon(Icons.error),
//                       ),
//                     ),
//                   )
//                 : SizedBox(width: 35, height: 35, child: Image.asset(AppImages.userProfile)),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width / 1.3),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(ctx).highlightColor),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${commenter.firstName} ${commenter.lastName}",
//                         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
//                         softWrap: true,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         comment.description,
//                         softWrap: true,
//                         overflow: TextOverflow.visible,
//                         style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     formatDuration(comment.createdAt),
//                     style: TextStyle(color: Theme.of(ctx).hintColor, fontSize: 10),
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

