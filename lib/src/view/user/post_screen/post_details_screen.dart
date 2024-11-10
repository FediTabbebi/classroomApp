import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/comment_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/comment_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/view/user/post_screen/widget/comment_header_widget.dart';
import 'package:classroom_app/src/view/user/post_screen/widget/comment_listtile_widget.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final int index;
  final bool isMyListPreview;
  const PostDetailsScreen({required this.index, required this.isMyListPreview, super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late FocusNode focusNode;
  final ClassroomService service = locator<ClassroomService>();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    // });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<List<ClassroomModel>?>(builder: (context, data, provider) {
      if (data == null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LaodingProgressWidget(
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        );
      } else if (data.isEmpty) {
        return Center(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: Text("There is no posts for the moment"),
            ),
          ),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              expandedHeight: 60.0,
              pinned: true,
              snap: true,
              floating: true,
              flexibleSpace: CommentHeaderWidget(
                classroom: data[widget.index],
                createdBy: data[widget.index].createdBy!,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0), child: Text(data[widget.index].label)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "${data[widget.index].comments!.length} comments",
                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                            )),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data[widget.index].comments!.length,
                        itemBuilder: (context, index) {
                          return CommentListTileWidget(
                            comment: data[widget.index].comments![index],
                            commenter: data[widget.index].comments![index].commentedBy!,
                          );
                        },
                      ),
                    ],
                  );
                },
                childCount: 1,
              ),
            )
          ],
        ),
        bottomNavigationBar: context.read<UserProvider>().currentUser!.role != "Admin"
            ? Container(
                constraints: const BoxConstraints(maxHeight: 100, minHeight: 80),
                color: Theme.of(context).cardTheme.color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                          size: 35,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Form(
                        key: context.read<CommentProvider>().commentFormKey,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 70, minHeight: 45),
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: TextFormField(
                            controller: context.read<CommentProvider>().postCommentController,
                            focusNode: focusNode,
                            style: const TextStyle(fontSize: 14.0, height: 1),
                            onChanged: (value) {
                              context.read<CommentProvider>().setCommentControllerText(value);
                            },
                            autofocus: true, // Always open the keyboard
                            decoration: InputDecoration(
                                hintStyle: const TextStyle(fontSize: 14.0, height: 1),
                                isDense: true,
                                alignLabelWithHint: true,
                                fillColor: Theme.of(context).cardTheme.color,
                                // isCollapsed: true,
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(30.0)),
                                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(30.0)),
                                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(30.0)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(30.0)),
                                hintText: 'Enter a comment...',
                                suffixIcon: const Icon(Icons.emoji_emotions_outlined)),
                            validator: (value) => validateEmptyFieldWithResponse(value, "Comment cannot be empty"),
                          ),
                        ),
                      ),
                    ),
                    Consumer<CommentProvider>(builder: (context, commentProvider, child) {
                      return IconButton(
                          onPressed: commentProvider.isAddingComment
                              ? null
                              : () async {
                                  if (commentProvider.commentFormKey.currentState!.validate()) {
                                    List<CommentModel> comments = data[widget.index].comments!;
                                    CommentModel currentComment = CommentModel(
                                        id: data[widget.index].id + context.read<UserProvider>().currentUser!.userId,
                                        description: commentProvider.postCommentController.text,
                                        commentedByRef: FirebaseFirestore.instance.doc('users/${context.read<UserProvider>().currentUser!.userId}'),
                                        isSeen: widget.isMyListPreview,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now());
                                    comments.add(currentComment);
                                    await commentProvider.addComment(
                                        context,
                                        ClassroomModel(
                                            id: data[widget.index].id,
                                            label: data[widget.index].label,
                                            colorHex: data[widget.index].colorHex,
                                            createdByRef: data[widget.index].createdByRef,
                                            createdAt: data[widget.index].createdAt,
                                            updatedAt: data[widget.index].updatedAt,
                                            comments: comments));
                                  }
                                },
                          icon: commentProvider.postCommentController.text.isEmpty
                              ? const SizedBox()
                              : commentProvider.isAddingComment
                                  ? LaodingProgressWidget(
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : Icon(
                                      Icons.send,
                                      color: Theme.of(context).colorScheme.primary,
                                    ));
                    })
                  ],
                ),
              )
            : Container(
                constraints: const BoxConstraints(maxHeight: 100, minHeight: 80),
                color: Theme.of(context).cardTheme.color,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.7,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red[900])),
                      onPressed: () async {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogWidget(
                                dialogTitle: "Delete confirmation",
                                dialogContent: "Are you sure you want to delete this post?",
                                isConfirmDialog: true,
                                onConfirm: () async {
                                  Navigator.pop(context);
                                  await context.read<ClassroomProvider>().deleteClassroom(context, data[widget.index].id).then((value) => Navigator.of(context).pop());
                                });
                          },
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Delete this post",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.delete)
                        ],
                      ),
                    ),
                  ),
                )),
      );
    });
  }
}
