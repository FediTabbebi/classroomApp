import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddUpdateFolderDialog extends StatefulWidget {
  final ClassroomModel classroom;
  final FolderModel? folderModel;
  const AddUpdateFolderDialog({required this.classroom, this.folderModel, super.key});

  @override
  State<AddUpdateFolderDialog> createState() => _AddUpdateFolderDialogState();
}

class _AddUpdateFolderDialogState extends State<AddUpdateFolderDialog> {
  bool _initialized = false;
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final classroomProvider = context.read<ClassroomProvider>();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        classroomProvider.clearFolderControllers(context);

        if (widget.folderModel != null) {
          classroomProvider.initFolderControllers(widget.folderModel!);
        }
      });

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        width: 500,
        child: Form(
          key: context.read<ClassroomProvider>().createFolderFormKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.folderModel != null ? "Update folder" : "Create Folder",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        size: 20,
                        FontAwesomeIcons.xmark,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26.0),
                const Text(
                  "Folder Label",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                textFieldWidget(
                    focusNode: _textFieldFocusNode,
                    hintText: "Enter folder label",
                    textEditingController: context.read<ClassroomProvider>().classroomFolderController,
                    validator: (value) => validateEmptyFieldWithResponse(value!, "Folder label cannot be empty"),
                    context: context),
                const SizedBox(height: 10),
                const Text(
                  "Folder Color",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10.0),
                colorPickerWidget(),
                const SizedBox(height: 26.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButtonWidget(
                    width: 81,
                    height: 40,
                    radius: 5,
                    onPressed: () async {
                      if (context.read<ClassroomProvider>().createFolderFormKey.currentState!.validate()) {
                        if (widget.folderModel != null) {
                          await context.read<ClassroomProvider>().updateFolder(context, widget.folderModel!, widget.classroom);
                        } else {
                          FolderModel currentFolder = FolderModel(
                            colorHex: colorToHex(context.read<ClassroomProvider>().folderSelectedColor!),
                            folderName: context.read<ClassroomProvider>().classroomFolderController.text,
                            createdByRef: FirebaseFirestore.instance.doc(
                              'users/${context.read<UserProvider>().currentUser!.userId}',
                            ),
                            files: [],
                            folderId: const Uuid().v1(),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

                          widget.classroom.folders!.add(currentFolder);
                          context.read<ClassroomProvider>().addFolderToClassRoom(context, widget.classroom);
                        }
                      }
                    },
                    text: widget.folderModel != null ? "Update" : 'Create',
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  textFieldWidget(
      {required TextEditingController textEditingController,
      required String hintText,
      required FocusNode focusNode,
      required String? Function(String?)? validator,
      required BuildContext context,
      Widget? suffixIcon,
      bool? obscureText,
      int? maxLines,
      bool readOnly = false}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 300),
      child: TextFormField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          focusNode: focusNode,
          controller: textEditingController,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            fillColor: Theme.of(context).cardTheme.color,
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
            hintText: hintText,
            errorStyle: const TextStyle(height: 1, fontSize: 14.0),
            hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1, fontSize: 14.0, color: Theme.of(context).hintColor),
            suffixIcon: suffixIcon,
          ),
          maxLines: maxLines,
          readOnly: readOnly,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 14.0, height: 1),
          validator: (value) => validator!(value)),
    );
  }

  Widget iconButton(BuildContext context, IconData iconData, Function() onTap, bool removeIcon) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
              child: Icon(
            color: Theme.of(context).colorScheme.primary,
            iconData,
            size: 12.5,
          )),
        ),
      ),
    );
  }

  Widget colorPickerWidget() {
    return PopupMenuButton<String>(
      constraints: const BoxConstraints(maxWidth: 460),
      tooltip: "",
      offset: const Offset(0, 60),
      padding: EdgeInsets.zero,
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: AppColors.colorOptions.map((color) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<ClassroomProvider>().updateFolderSelectedColor(color);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ))
      ],
      child: Container(
          alignment: const AlignmentDirectional(-1, 0),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffD3D7DB))),
          height: 50,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Pick folder color",
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                ),
              ),
              Selector<ClassroomProvider, Color?>(
                  selector: (context, provider) => provider.folderSelectedColor,
                  builder: (context, folderSelectedColor, child) {
                    return Container(
                      width: 25,
                      height: 25,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: folderSelectedColor,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
              const Icon(Icons.arrow_drop_down)
            ],
          )),
    );
  }
}
