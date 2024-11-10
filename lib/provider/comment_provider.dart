import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:go_router/go_router.dart';

class CommentProvider with ChangeNotifier {
  ClassroomService service = locator<ClassroomService>();
  final GlobalKey<FormState> commentFormKey = GlobalKey<FormState>();
  final TextEditingController postCommentController = TextEditingController();

  bool isAddingComment = false;
  Future<void> addComment(BuildContext context, ClassroomModel post) async {
    isAddingComment = true;
    notifyListeners();
    postCommentController.clear();
    await service.updateClassroom(post).then((value) async {
      isAddingComment = false;
      notifyListeners();
    }).onError((error, stackTrace) {
      isAddingComment = false;
      notifyListeners();
      showingDialog(context, "errors", '$error');
    });
  }

  setCommentControllerText(String value) {
    postCommentController.text = value;
    notifyListeners();
  }

  Future<void> updatePost(BuildContext context, ClassroomModel post, int index) async {
    BuildContext? dialogContext;
    showAnimatedDialog<void>(
        animationType: DialogTransitionType.scale,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return UnconstrainedBox(
            child: LaodingProgressWidget(
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        });
    //  notifyListeners();
    for (int i = 0; i < post.comments!.length; i++) {
      if (post.comments![i].isSeen == false) {
        post.comments![i].isSeen = false;
      }
    }

    await service.updateClassroom(post).then((value) async {
      Navigator.of(dialogContext!).pop();

      context.pushNamed("myPostDetails", extra: index); //  notifyListeners();
    }).onError((error, stackTrace) {
      Navigator.of(dialogContext!).pop();
      showingDialog(context, "errors", '$error');
    });
  }

  Future<void> showingDialog(
    BuildContext context,
    String title,
    String contents,
  ) async {
    await showAnimatedDialog<void>(
        context: context,
        barrierDismissible: true,
        duration: const Duration(milliseconds: 150),
        builder: (BuildContext context) {
          return DialogWidget(
            dialogTitle: title,
            dialogContent: contents,
            onConfirm: () {
              //  Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        });
  }
}
