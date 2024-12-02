import 'package:classroom_app/constant/app_colors.dart';
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

class ClassroomListitleWidget extends StatelessWidget {
  final ClassroomModel classroom;
  final void Function()? onTap;

  const ClassroomListitleWidget({required this.classroom, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).dialogBackgroundColor,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading section: Classroom icon and abbreviation
              Container(
                alignment: Alignment.center,
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: hexToColor(classroom.colorHex),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  getAbbreviation(classroom.label),
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classroom.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      classroom.createdBy?.email ?? '',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                  ],
                ),
              ),

              // Trailing section (Admin-specific)

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      formatDate(classroom.createdAt),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (context.read<UserProvider>().currentUser!.role!.id != "3") menuWidget(context, classroom),
                ],
              ),
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
              child: const Text(
                "Delete",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
            ),
          ]);
}
