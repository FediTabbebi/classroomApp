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
  @override
  void initState() {
    super.initState();
    context.read<ClassroomProvider>().clearControllers();

    if (widget.classroom != null) {
      context.read<ClassroomProvider>().initControllers(widget.classroom!);
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
                  Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<ClassroomProvider>().clearControllers();
                        },
                        child: Icon(
                          size: 20,
                          FontAwesomeIcons.xmark,
                          color: Theme.of(context).hintColor,
                        ),
                      )),
                  Text(
                    widget.classroom != null ? "Update Classroom" : "Create Classroom",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Classroom Label",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10.0),
                  textFieldWidget(
                      hintText: "Enter classroom label",
                      textEditingController: context.read<ClassroomProvider>().classroomLabelController,
                      validator: (value) => validateEmptyFieldWithResponse(value!, "classroom label cannot be empty"),
                      context: context),
                  const SizedBox(height: 10),
                  Consumer<ClassroomProvider>(builder: (context, provider, child) {
                    return Column(
                      children: [
                        inviteUsersWidget(),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButtonWidget(
                      width: widget.classroom != null ? 75 : 75,
                      height: 40,
                      radius: 5,
                      onPressed: () {
                        if (context.read<ClassroomProvider>().classRoomFormKey.currentState!.validate()) {
                          final List<String> selectedUsers = [];
                          context.read<ClassroomProvider>().selectedUsers.forEach((e) => selectedUsers.add(e.userId));

                          // Check if selectedUsers is not empty and map their IDs to document references
                          List<DocumentReference> invitedUsersRef = [];
                          if (selectedUsers.isNotEmpty) {
                            invitedUsersRef = selectedUsers.map((userId) {
                              return FirebaseFirestore.instance.doc('users/$userId');
                            }).toList();
                          }

                          // Create the ClassroomModel with all necessary fields
                          context.read<ClassroomProvider>().addClassroom(
                                context,
                                ClassroomModel(
                                  id: '',
                                  invitedUsersRef: invitedUsersRef, // Insert the mapped document references
                                  label: context.read<ClassroomProvider>().classroomLabelController.text,
                                  colorHex: '#FFFFFF', // Provide a default or selected color in hex format
                                  comments: [],
                                  createdByRef: FirebaseFirestore.instance.doc('users/${context.read<UserProvider>().currentUser!.userId}'),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        }
                      },
                      // widget.post != null
                      //     ? context.read<CategoryProvider>().updateCategory(
                      //           context,
                      //           widget.post!,
                      //         )
                      //     : context.read<CategoryProvider>().addCategory(
                      //           context,
                      //           CategoryModel(
                      //               id: "",
                      //               label: context
                      //                   .read<CategoryProvider>()
                      //                   .labelController
                      //                   .text,
                      //               createdAt: DateTime.now(),
                      //               updatedAt: DateTime.now()),
                      //         );

                      text: widget.classroom != null ? 'Update' : 'Create',
                      fontSize: 12,
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
            // isCollapsed: true,
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
            hintText: hintText,

            errorStyle: const TextStyle(
              height: 1,
              fontSize: 14.0,
            ),

            hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1, fontSize: 14.0, color: Theme.of(context).hintColor),

            // isDense: true,
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
        borderRadius: const BorderRadius.all(
          Radius.circular(
            50,
          ),
        ),
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
        const Text("Invite users", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 10.0),
        DropdownSearch<UserModel>.multiSelection(
          dropdownBuilder: (context, selected) {
            context.read<ClassroomProvider>().selectedUsers = selected;
            return Text(
              "Select users",
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

          // suffixProps: const DropdownSuffixProps(
          //   clearButtonProps:
          //       ClearButtonProps(isVisible: true),
          // ),
          key: context.read<ClassroomProvider>().usersKey,
          asyncItems: (string) {
            return context.read<UserProvider>().getUsersAsFuture(context);
          },
          // validator: (value) => validateEmptyListWithResponse(value, "please select a user"),
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
                    fontSize: 12.0,
                  ),
                  hintText: "Search for a user")),
          popupProps: PopupPropsMultiSelection.menu(
            // showSelectedItems: true,
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
                  //  isDense: true,
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
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${context.read<ClassroomProvider>().selectedUsers.length} selected user(s)",
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
            ),
          )
      ],
    );
  }
}
