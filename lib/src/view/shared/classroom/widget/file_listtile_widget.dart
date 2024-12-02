import 'package:auto_size_text/auto_size_text.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/download_helper.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/utils/file_icon_helper.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FileListtile extends StatelessWidget {
  final FileModel file;
  final String? folderId;
  final ClassroomModel classroom;
  final String roleModel;
  FileListtile({required this.file, required this.classroom, this.folderId, required this.roleModel, super.key});

  final downloadHelper = locator<FileDownloadHelper>();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FileIconHelper.getWidgetForFile(
        extension: file.fileType,
        imageUrl: file.fileUrl, // Pass the URL for images
        iconSize: 40.0, // Optional size customization
      ),
      title: AutoSizeText(
        minFontSize: 12,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        getFileNameWithoutExtension(file.fileName),
      ),
      subtitle: Text(
        "Uploaded At ${formatDate(file.uploadedAt)}",
        style: const TextStyle(fontSize: 10, color: AppColors.darkGrey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: "${file.sender?.firstName} ${file.sender?.lastName}",
              child: SizedBox(
                width: 120,
                child: Text(
                  "By ${file.sender?.firstName} ${file.sender?.lastName}",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.darkGrey, fontSize: 12),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
                    leadingIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        FontAwesomeIcons.downLong,
                        color: Theme.of(context).colorScheme.primary,
                        size: 17.5,
                      ),
                    ),
                    child: const Text(
                      "Download",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    onPressed: () async {
                      // After permission is granted, proceed with the download logic
                      if (context.read<AppService>().isMobileDevice) {
                        // await context.read<ClassroomProvider>().requestStoragePermission();
                        await downloadHelper.downloadFileFromFirebase("Classroom files/${classroom.id}/${file.fileName}", file.fileName);

                        // await context.read<ClassroomProvider>().downloadFileFromFirebase("Classroom files/${widget.classroom.id}/${file.fileName}", file.fileName);
                      } else {
                        await context
                            .read<ClassroomProvider>()
                            .downloadFileFromFirebaseWeb(firebasePath: "Classroom files/${classroom.id}/${file.fileName}", fileName: file.fileName, context: context);
                      }
                    },
                  ),
                ),
                if (roleModel == "1" || roleModel == "2" || roleModel == file.sender!.role!.id)
                  SizedBox(
                    width: 150,
                    child: MenuItemButton(
                      onPressed: () async {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogWidget(
                              dialogTitle: "Delete confirmation",
                              dialogContent: "Are you sure you want to delete this file?",
                              isConfirmDialog: true,
                              onConfirm: () async {
                                Navigator.pop(context);
                                if (folderId != null) {
                                  await context.read<ClassroomProvider>().deleteFileFromFolder(context, classroom, file.fileId, folderId!).then((value) {});
                                } else {
                                  await context.read<ClassroomProvider>().deleteFileFromClassroom(context, classroom, file.fileId);
                                }
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

  String getFileNameWithoutExtension(String fileName) {
    // Find the last index of the period (.) and remove the extension.
    int index = fileName.lastIndexOf('.');
    if (index != -1) {
      return fileName.substring(0, index); // Remove the extension
    } else {
      return fileName; // In case there is no extension
    }
  }
}
