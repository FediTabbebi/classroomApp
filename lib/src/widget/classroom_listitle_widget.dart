import 'package:classroom_app/model/classroom_model.dart';
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

  const ClassroomListitleWidget({required this.classroom, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
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
            const SizedBox(width: 16), // Spacing between leading and text

            // Title and subtitle section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (Classroom label)
                  Text(
                    classroom.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4), // Spacing between title and subtitle

                  // Subtitle (Created by email)
                  Text(
                    classroom.createdBy?.email ?? '',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Trailing section (Admin-specific)
            if (context.read<UserProvider>().currentUser!.role == "Admin")
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
                  menuWidget(context, classroom),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget menuWidget(BuildContext context, ClassroomModel classroom) => MenuAnchor(
          alignmentOffset: const Offset(-80, -30),
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
              child: const SizedBox(
                width: 100,
                child: Text(
                  "Edit",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            MenuItemButton(
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
