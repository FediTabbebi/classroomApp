import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AddOrUpdateClassroomDialog extends StatefulWidget {
  final ClassroomModel? classroom;
  const AddOrUpdateClassroomDialog({this.classroom, super.key});

  @override
  State<AddOrUpdateClassroomDialog> createState() => _AddOrUpdateUserDialogState();
}

class _AddOrUpdateUserDialogState extends State<AddOrUpdateClassroomDialog> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final classroomProvider = context.read<ClassroomProvider>();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        classroomProvider.clearControllers(context);

        if (widget.classroom != null) {
          classroomProvider.initControllers(widget.classroom!);
        }
      });

      _initialized = true;
    }
  }

  final List<Color> colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: SizedBox(
          width: 500,
          child: Form(
            key: context.read<ClassroomProvider>().classRoomFormKey,
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
                        widget.classroom != null ? "Update Classroom" : "Create Classroom",
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
                    "Classroom Label",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  textFieldWidget(
                      hintText: "Enter classroom label",
                      textEditingController: context.read<ClassroomProvider>().classroomLabelController,
                      validator: (value) => validateEmptyFieldWithResponse(value!, "Classroom label cannot be empty"),
                      context: context),
                  const SizedBox(height: 10),
                  Consumer<ClassroomProvider>(builder: (context, provider, child) {
                    return Column(
                      children: [
                        inviteUsersWidget(),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),
                  const Text(
                    "Thumbnail Color",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10.0),
                  colorPickerWidget(),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButtonWidget(
                      width: 81,
                      height: 40,
                      radius: 5,
                      onPressed: () {
                        if (context.read<ClassroomProvider>().classRoomFormKey.currentState!.validate()) {
                          final List<String> selectedUsers = [];
                          context.read<ClassroomProvider>().selectedUsers.forEach((e) => selectedUsers.add(e.userId));
                          List<DocumentReference> invitedUsersRef = [];
                          if (selectedUsers.isNotEmpty) {
                            invitedUsersRef = selectedUsers.map((userId) {
                              return FirebaseFirestore.instance.doc('users/$userId');
                            }).toList();
                          }
                          widget.classroom != null
                              ? context.read<ClassroomProvider>().updateClassroom(context, widget.classroom!)
                              : context.read<ClassroomProvider>().addClassroom(
                                    context,
                                    ClassroomModel(
                                      id: '',
                                      invitedUsersRef: invitedUsersRef, // Insert the mapped document references
                                      label: context.read<ClassroomProvider>().classroomLabelController.text,
                                      colorHex: colorToHex(context.read<ClassroomProvider>().selectedColor!), // Provide a default or selected color in hex format
                                      comments: [],
                                      files: [],
                                      createdByRef: FirebaseFirestore.instance.doc('users/${context.read<UserProvider>().currentUser!.userId}'),
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                  );
                        }
                      },
                      text: widget.classroom != null ? 'Update' : 'Create',
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  textFieldWidget(
      {required TextEditingController textEditingController,
      required String hintText,
      required String? Function(String?)? validator,
      required BuildContext context,
      Widget? suffixIcon,
      bool? obscureText,
      int? maxLines,
      bool readOnly = false}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 300),
      child: TextFormField(
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

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  Widget inviteUsersWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Invite Users", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 10.0),
        DropdownSearch<UserModel>.multiSelection(
          dropdownBuilder: (context, selected) {
            context.read<ClassroomProvider>().selectedUsers = selected;
            return Text(
              "Select Users",
              textAlign: TextAlign.start,
              style: TextStyle(height: 1.5, fontSize: 14.0, color: Theme.of(context).hintColor),
            );
          },
          itemAsString: (item) {
            return item.email;
          },
          filterFn: (item, filter) {
            if (item.email.toLowerCase().contains(filter.toLowerCase())) {
              return true;
            } else {
              return false;
            }
          },
          key: context.read<ClassroomProvider>().usersKey,
          asyncItems: (string) {
            return context.read<UserProvider>().getUsersAsFuture(context);
          },
          onChanged: (newValue) {
            context.read<ClassroomProvider>().addNewUsers(
                  newValue,
                );
          },
          selectedItems: context.read<ClassroomProvider>().selectedUsers,
          compareFn: (item, selectedItem) => item.email == selectedItem.email,
          dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.transparent)),
                  filled: false,
                  hintStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                  hintText: "Search for a user")),
          popupProps: PopupPropsMultiSelection.menu(
            searchDelay: Duration.zero,
            menuProps: MenuProps(backgroundColor: Theme.of(context).colorScheme.surface),
            onItemAdded: (l, s) => context.read<ClassroomProvider>().handleCheckBoxState(
                  popupBuilderKey: context.read<ClassroomProvider>().usersPopupBuilderKey,
                  popupBuilderSelection: context.read<ClassroomProvider>().usersPopupBuilderSelection,
                ),
            onItemRemoved: (l, s) => context.read<ClassroomProvider>().handleCheckBoxState(
                  popupBuilderKey: context.read<ClassroomProvider>().usersPopupBuilderKey,
                  popupBuilderSelection: context.read<ClassroomProvider>().usersPopupBuilderSelection,
                ),
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 14.0,
                ),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(fontSize: 14, height: 3.5),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Themes.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Theme.of(context).highlightColor), borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                  filled: true,
                  fillColor: Theme.of(context).dialogBackgroundColor,
                  hintText: "Search for a user",
                )),
            loadingBuilder: (context, searchEntry) {
              return const Center(child: LoadingIndicatorWidget(size: 40));
            },
            emptyBuilder: (context, searchEntry) {
              return const Center(child: Text("No data found"));
            },
            containerBuilder: (context, popupWidget) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.all(8),
                        child: TextButton(
                          onPressed: () {
                            context.read<ClassroomProvider>().usersKey.currentState?.popupDeselectAllItems();
                          },
                          child: const Text("None"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.all(8),
                        child: TextButton(
                          onPressed: () {
                            context.read<ClassroomProvider>().usersKey.currentState?.popupSelectAllItems();
                          },
                          child: const Text("All"),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: popupWidget),
                ],
              );
            },
          ),
        ),
        if (context.read<ClassroomProvider>().selectedUsers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: Text(
              "${context.read<ClassroomProvider>().selectedUsers.length} selected user(s)",
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
            ),
          )
      ],
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
                  children: colorOptions.map((color) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: () {
                        context.read<ClassroomProvider>().updateSelectedColor(color);
                        Navigator.pop(ctx);
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
                  "Pick a color for the classroom thumbnail",
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                ),
              ),
              Container(
                width: 25,
                height: 25,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: context.watch<ClassroomProvider>().selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(Icons.arrow_drop_down)
            ],
          )),
    );
  }
}
