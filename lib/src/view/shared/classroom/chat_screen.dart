import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/message_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/message_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/message_listtile_widget.dart';
import 'package:classroom_app/src/widget/loading_progress_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final ClassroomModel classroom;
  const ChatScreen({required this.classroom, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late FocusNode focusNode;
  final ClassroomService service = locator<ClassroomService>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController emojiScroll = ScrollController();
  final GlobalKey<FormState> commentFormKey = GlobalKey<FormState>();
  late final TextEditingController postCommentController;
  late FocusNode listenerFocusNode;
  bool _emojiShowing = false;
  final ScrollController _textFieldScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    listenerFocusNode = FocusNode();
    postCommentController = TextEditingController();

    // Request focus on the FocusNode directly here
    focusNode.requestFocus();

    // Scroll to the bottom when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scroll to the bottom if the message list updates
    if (oldWidget.classroom.messages != widget.classroom.messages) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    // Dispose resources
    focusNode.dispose();
    listenerFocusNode.dispose();
    postCommentController.dispose();
    _scrollController.dispose();
    emojiScroll.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.classroom.messages!.isEmpty
            ? GestureDetector(
                onTap: () {
                  if (_emojiShowing) {
                    setState(() {
                      _emojiShowing = !_emojiShowing;
                    });
                  }
                },
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Text("This classroom has no chat at the moment")),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  if (_emojiShowing) {
                    setState(() {
                      _emojiShowing = !_emojiShowing;
                    });
                  }
                },
                child: ListView.builder(
                  controller: _scrollController,
                  //shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  //  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.classroom.messages!.length,
                  itemBuilder: (context, index) {
                    return MessageListTileWidget(
                      message: widget.classroom.messages![index],
                      sender: widget.classroom.messages![index].sender,
                    );
                  },
                ),
              ),
        bottomNavigationBar:

            //  context.read<UserProvider>().currentUser!.role != "aa"
            //     ?
            Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 100, minHeight: 80),
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MenuAnchor(
                      alignmentOffset: const Offset(5, 20),
                      builder: (BuildContext context, MenuController controller, Widget? child) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                              style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(4))),
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              icon: Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                              tooltip: "Options"),
                        );
                      },
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () async {},
                          leadingIcon: Icon(
                            FontAwesomeIcons.image,
                            color: Theme.of(context).colorScheme.primary,
                            size: 17.5,
                          ),
                          child: const SizedBox(
                            width: 100,
                            child: Text(
                              "Media",
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ),
                        ),
                        MenuItemButton(
                          leadingIcon: Icon(
                            FontAwesomeIcons.paperclip,
                            color: Theme.of(context).colorScheme.primary,
                            size: 17.5,
                          ),
                          child: const Text(
                            "File",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          onPressed: () async {},
                        ),
                      ]),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Form(
                        key: commentFormKey,
                        child: Consumer<MessageProvider>(builder: (context, commentProvider, child) {
                          return KeyboardListener(
                            focusNode: listenerFocusNode,
                            onKeyEvent: (event) async {
                              if (event is KeyDownEvent) {
                                // Check if the Enter key is pressed
                                if (event.logicalKey == LogicalKeyboardKey.enter) {
                                  // Check if Shift is pressed by looking at the event's modifiers
                                  final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                                  if (isShiftPressed) {
                                    final newText = '${postCommentController.text}\n';
                                    postCommentController.text = newText;
                                    postCommentController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: newText.length),
                                    );
                                  } else {
                                    // Otherwise, trigger the send action
                                    if (!commentProvider.isAddingComment) {
                                      FocusScope.of(context).unfocus(); // Hide keyboard
                                      if (commentFormKey.currentState!.validate()) {
                                        List<MessageModel> messages = widget.classroom.messages!;
                                        MessageModel currentComment = MessageModel(
                                          id: widget.classroom.id + context.read<UserProvider>().currentUser!.userId,
                                          description: postCommentController.text,
                                          senderRef: FirebaseFirestore.instance.doc(
                                            'users/${context.read<UserProvider>().currentUser!.userId}',
                                          ),
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                        );
                                        messages.add(currentComment);
                                        await commentProvider
                                            .addMessage(
                                                context,
                                                ClassroomModel(
                                                    folders: widget.classroom.folders,
                                                    id: widget.classroom.id,
                                                    label: widget.classroom.label,
                                                    colorHex: widget.classroom.colorHex,
                                                    invitedUsersRef: widget.classroom.invitedUsersRef,
                                                    invitedUsers: widget.classroom.invitedUsers,
                                                    createdBy: widget.classroom.createdBy,
                                                    createdByRef: widget.classroom.createdByRef,
                                                    createdAt: widget.classroom.createdAt,
                                                    updatedAt: widget.classroom.updatedAt,
                                                    messages: messages))
                                            .then((value) {
                                          postCommentController.clear();
                                        });
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 70, minHeight: 45),
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                scrollController: _textFieldScrollController,
                                controller: postCommentController,
                                focusNode: focusNode,
                                style: const TextStyle(fontSize: 14.0, height: 1),
                                onChanged: (value) {
                                  context.read<MessageProvider>().setMessageControllerText(value);
                                },
                                maxLines: 3,
                                minLines: 1,
                                autofocus: true, // Always open the keyboard
                                decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                      fontSize: 14.0,
                                      height: 1,
                                      color: AppColors.darkGrey,
                                    ),
                                    isDense: true,
                                    alignLabelWithHint: true,
                                    fillColor: Theme.of(context).cardTheme.color,
                                    // isCollapsed: true,
                                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(10.0)),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
                                    focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(10.0)),
                                    hintText: 'Type a message...',
                                    suffixIcon: context.read<AppService>().isMobileDevice
                                        ? null
                                        : InkWell(
                                            onTap: () {
                                              setState(() {
                                                _emojiShowing = !_emojiShowing;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.emoji_emotions_outlined,
                                              color: AppColors.darkGrey,
                                              size: 22.5,
                                            ))),
                                validator: (value) => validateEmptyFieldWithResponse(value, "Message cannot be empty"),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Consumer<MessageProvider>(builder: (context, commentProvider, child) {
                    return commentProvider.message.isEmpty
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                                onPressed: commentProvider.isAddingComment
                                    ? null
                                    : () async {
                                        if (commentFormKey.currentState!.validate()) {
                                          List<MessageModel> messages = widget.classroom.messages!;
                                          MessageModel currentComment = MessageModel(
                                              id: widget.classroom.id + context.read<UserProvider>().currentUser!.userId,
                                              description: postCommentController.text,
                                              senderRef: FirebaseFirestore.instance.doc('users/${context.read<UserProvider>().currentUser!.userId}'),
                                              createdAt: DateTime.now(),
                                              updatedAt: DateTime.now());
                                          messages.add(currentComment);
                                          await commentProvider
                                              .addMessage(
                                                  context,
                                                  ClassroomModel(
                                                      id: widget.classroom.id,
                                                      label: widget.classroom.label,
                                                      colorHex: widget.classroom.colorHex,
                                                      invitedUsersRef: widget.classroom.invitedUsersRef,
                                                      invitedUsers: widget.classroom.invitedUsers,
                                                      createdBy: widget.classroom.createdBy,
                                                      files: widget.classroom.files,
                                                      folders: widget.classroom.folders,
                                                      createdByRef: widget.classroom.createdByRef,
                                                      createdAt: widget.classroom.createdAt,
                                                      updatedAt: widget.classroom.updatedAt,
                                                      messages: messages))
                                              .then((value) {
                                            postCommentController.clear();
                                          });
                                        }
                                      },
                                icon: commentProvider.isAddingComment
                                    ? LaodingProgressWidget(
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : Icon(
                                        Icons.send,
                                        color: Theme.of(context).colorScheme.primary,
                                      )),
                          );
                  })
                ],
              ),
            ),
            Offstage(
              offstage: !_emojiShowing,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      context.read<MessageProvider>().setMessageControllerText(emoji.emoji);
                    },
                    textEditingController: postCommentController,
                    scrollController: emojiScroll,
                    config: Config(
                      height: 200,
                      checkPlatformCompatibility: false,
                      viewOrderConfig: const ViewOrderConfig(),
                      emojiViewConfig: EmojiViewConfig(
                        columns: ResponsiveWidget.isLargeScreen(context) ? 20 : 6,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        emojiSizeMax: ResponsiveWidget.isLargeScreen(context) ? 25 : 22.5,
                      ),
                      skinToneConfig: SkinToneConfig(
                        dialogBackgroundColor: Theme.of(context).cardTheme.color!,
                        indicatorColor: AppColors.darkGrey,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        dividerColor: Theme.of(context).highlightColor,
                        iconColorSelected: Theme.of(context).colorScheme.primary,
                        backspaceColor: Theme.of(context).colorScheme.primary,
                        iconColor: AppColors.darkGrey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).cardTheme.color!,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: Theme.of(context).cardTheme.color!,
                        buttonIconColor: Theme.of(context).colorScheme.primary,
                        buttonColor: Theme.of(context).cardTheme.color!,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: Theme.of(context).cardTheme.color!,
                        hintTextStyle: const TextStyle(
                          fontSize: 14.0,
                          height: 1,
                          color: AppColors.darkGrey,
                        ),
                        buttonIconColor: Theme.of(context).textTheme.bodyMedium!.color!,
                        inputTextStyle: const TextStyle(fontSize: 14.0, height: 1),
                      ),
                    ),
                  ),
                  Container(color: Theme.of(context).cardTheme.color, height: 10)
                ],
              ),
            ),
          ],
        ));
  }
}
