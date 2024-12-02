import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/add_update_classroom_dialog.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ClassroomCardWidget extends StatelessWidget {
  final ClassroomModel classroom;
  final void Function()? onTap;
  const ClassroomCardWidget({required this.onTap, required this.classroom, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Fixed width
      height: 320,
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Card(
          elevation: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(color: hexToColor(classroom.colorHex), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      // classroom.label,
                      getAbbreviation(classroom.label),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  Visibility(visible: context.read<UserProvider>().currentUser!.role!.id != "3", child: Positioned(right: 10, top: 15, child: menuWidget(context, classroom))),
                  Positioned(
                      bottom: 10,
                      left: 15,
                      child: Visibility(
                        visible: context.read<UserProvider>().currentUser!.role!.id != "3",
                        child: classroom.invitedUsers != null
                            ? (classroom.invitedUsers!.isNotEmpty)
                                ? Row(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 230,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: classroom.invitedUsers!.length > 6 ? classroom.invitedUsers!.sublist(0, 6).length : classroom.invitedUsers!.length,
                                          itemBuilder: (context, index) {
                                            return Tooltip(
                                              showDuration: const Duration(milliseconds: 0),
                                              message: classroom.invitedUsers![index].email,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                  // color: randomColor(),
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: const EdgeInsets.only(right: 8),
                                                child: Center(
                                                  child: Text(
                                                    classroom.invitedUsers![index].email.substring(0, 2),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (classroom.invitedUsers!.length > 6 && classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 6).length > 0)
                                        Tooltip(
                                          showDuration: const Duration(milliseconds: 0),
                                          message: "+"
                                              "${classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 6).length}"
                                              "${classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 6).length > 1 ? " members are assigned to this classroom" : " member is assigned to this classroom"}",
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            // margin: const EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                "+"
                                                '${classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 6).length}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "This classroom has no members",
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  )
                            : const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "This classroom has no members",
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                )),
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classroom.label,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      "${classroom.createdBy?.email}",
                      style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8),
                  child: Text(
                    formatDate(classroom.createdAt),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget menuWidget(BuildContext context, ClassroomModel classroom) => MenuAnchor(
          alignmentOffset: const Offset(-120, -30),
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: "Options");
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () async {
                showAnimatedDialog<void>(
                    barrierDismissible: false,
                    animationType: DialogTransitionType.fadeScale,
                    duration: const Duration(milliseconds: 300),
                    context: context,
                    builder: (BuildContext context) {
                      return AddOrUpdateClassroomDialog(
                        classroom: classroom,
                      );
                    });
              },
              leadingIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    FontAwesomeIcons.pen,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  )),
              child: const SizedBox(
                width: 100,
                child: Text(
                  "Edit",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            MenuItemButton(
              leadingIcon: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(FontAwesomeIcons.trash, size: 20, color: Colors.red)),
              onPressed: () async {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogWidget(
                      dialogTitle: "Delete confirmation",
                      dialogContent: "Are you sure you want to delete this classroom?",
                      isConfirmDialog: true,
                      onConfirm: () async {
                        Navigator.pop(context);
                        await context.read<ClassroomProvider>().deleteClassroom(context, classroom.id);
                      },
                    );
                  },
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ]);
}
