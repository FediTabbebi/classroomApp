import 'package:auto_size_text/auto_size_text.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/src/widget/add_update_folder_dialog.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FolderListtileWidget extends StatelessWidget {
  final FolderModel folder;
  final ClassroomModel classroom;
  final String roleModel;
  final void Function()? onTap;
  const FolderListtileWidget({required this.folder, required this.roleModel, required this.onTap, required this.classroom, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.folder, size: 48.0, color: hexToColor(folder.colorHex)),
      title: AutoSizeText(minFontSize: 12, maxLines: 2, softWrap: true, overflow: TextOverflow.ellipsis, folder.folderName),
      subtitle: Text(
        "Uploaded At ${formatDate(folder.createdAt)}",
        style: const TextStyle(fontSize: 10, color: AppColors.darkGrey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: "${folder.createdBy?.firstName} ${folder.createdBy?.lastName}",
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 120,
                child: Text(
                  "By ${folder.createdBy?.firstName} ${folder.createdBy?.lastName}",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.darkGrey, fontSize: 12),
                ),
              ),
            ),
          ),
          MenuAnchor(
              alignmentOffset: const Offset(-130, -35),
              builder: (BuildContext context, MenuController controller, Widget? child) {
                return InkWell(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: const Icon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: AppColors.darkGrey,
                    size: 20,
                  ),
                );
              },
              menuChildren: [
                SizedBox(
                  width: 150,
                  child: MenuItemButton(
                    onPressed: onTap,
                    leadingIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        FontAwesomeIcons.arrowRightFromBracket,
                        color: Theme.of(context).colorScheme.primary,
                        size: 17.5,
                      ),
                    ),
                    child: const SizedBox(
                      width: 100,
                      child: Text(
                        "Open",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                if (roleModel == "1" || roleModel == "2" || roleModel == folder.createdBy!.role!.id)
                  SizedBox(
                    width: 150,
                    child: MenuItemButton(
                      onPressed: () async {
                        showAnimatedDialog<void>(
                            barrierDismissible: false,
                            animationType: DialogTransitionType.fadeScale,
                            duration: const Duration(milliseconds: 300),
                            context: context,
                            builder: (BuildContext context) {
                              return AddUpdateFolderDialog(
                                classroom: classroom,
                                folderModel: folder,
                              );
                            });
                      },
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          FontAwesomeIcons.pen,
                          color: Theme.of(context).colorScheme.primary,
                          size: 17.5,
                        ),
                      ),
                      child: const SizedBox(
                        width: 100,
                        child: Text(
                          "Edit",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                if (roleModel == "1" || roleModel == "2" || roleModel == folder.createdBy!.role!.id)
                  SizedBox(
                    width: 150,
                    child: MenuItemButton(
                      onPressed: () async {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogWidget(
                              dialogTitle: "Delete confirmation",
                              dialogContent: "Are you sure you want to delete this folder?",
                              isConfirmDialog: true,
                              onConfirm: () async {
                                Navigator.pop(context);
                                await context.read<ClassroomProvider>().deleteFolderFromClassroom(context, classroom, folder.folderId);
                              },
                            );
                          },
                        );
                      },
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          FontAwesomeIcons.trashCan,
                          color: Theme.of(context).colorScheme.primary,
                          size: 17.5,
                        ),
                      ),
                      child: const SizedBox(
                        width: 100,
                        child: Text(
                          "Delete",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
              ]),
        ],
      ),
    );
  }
}
