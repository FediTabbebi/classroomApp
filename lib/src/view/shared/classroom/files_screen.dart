import 'package:auto_size_text/auto_size_text.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/download_helper.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/utils/extension_helper.dart';
import 'package:classroom_app/utils/file_icon_helper.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FilesScreen extends StatefulWidget {
  final ClassroomModel classroom;

  const FilesScreen({required this.classroom, super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late final ScrollController _scrollController;
  late final String userRole;
  final downloadHelper = FileDownloadHelper();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    userRole = context.read<UserProvider>().currentUser!.role!.id;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 50,
          child: Row(
              children: [
            ElevatedButtonWidget(
              radius: 3,
              height: 30,
              width: 107,
              onPressed: () {},
              text: "Folder",
              iconData: Icons.add,
            ),
            InkWell(
              onTap: () async {
                if (context.read<AppService>().isMobileDevice) {
                  await context.read<ClassroomProvider>().pickAndUploadFileWithNotification(context, widget.classroom, context.read<UserProvider>().currentUser!);
                } else {
                  await context.read<ClassroomProvider>().pickAndUploadFileAndUpdateClassroom(context, widget.classroom, context.read<UserProvider>().currentUser!);
                }
              },
              child: SizedBox(
                width: 107,
                height: 30,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.upload_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Text("Upload"),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: SizedBox(
                width: 107,
                height: 30,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.grid_on_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Text("Grid View"),
                    ],
                  ),
                ),
              ),
            )
          ].divide(const SizedBox(width: 10))),
        ),
        Expanded(
          child: widget.classroom.files!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Center(
                      child: Text(
                    "This classroom has no uploaded files at the moment",
                    textAlign: TextAlign.center,
                  )),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  controller: _scrollController,
                  //  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.classroom.files!.length,
                  itemBuilder: (context, index) {
                    final file = widget.classroom.files![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: FileIconHelper.getWidgetForFile(
                        extension: file.fileType,
                        imageUrl: file.fileUrl, // Pass the URL for images
                        iconSize: 48.0, // Optional size customization
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
                            child: Text(
                              "By ${file.sender?.firstName} ${file.sender?.lastName}",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.darkGrey, fontSize: 12),
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
                                        FontAwesomeIcons.download,
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
                                        await downloadHelper.downloadFileFromFirebase("Classroom files/${widget.classroom.id}/${file.fileName}", file.fileName);

                                        // await context.read<ClassroomProvider>().downloadFileFromFirebase("Classroom files/${widget.classroom.id}/${file.fileName}", file.fileName);
                                      } else {
                                        await context.read<ClassroomProvider>().downloadFileFromFirebaseWeb("Classroom files/${widget.classroom.id}/${file.fileName}");
                                      }
                                    },
                                  ),
                                ),
                                if (userRole == "1" || userRole == "2" || userRole == file.sender!.role!.id)
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
                                                await context.read<ClassroomProvider>().deleteFileFromClassroom(context, widget.classroom, file.fileId);
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
                  },
                ),
        ),
      ],
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
