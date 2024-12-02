import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/upload_helper.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/view/shared/classroom/inside_folder_screen.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/file_listtile_widget.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/folder_listtile_widget.dart';
import 'package:classroom_app/src/widget/add_update_folder_dialog.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:provider/provider.dart';

class FilesScreen extends StatefulWidget {
  final ClassroomModel classroom;

  const FilesScreen({required this.classroom, super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late final ScrollController _scrollController;
  late final String roleModel;
  final uploadHelper = locator<UploadHelper>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    roleModel = context.read<UserProvider>().currentUser!.role!.id;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ClassroomProvider, bool>(
        selector: (context, provider) => provider.isInsideFolder,
        builder: (context, isInsideFolder, child) {
          return Column(
            children: [
              if (!isInsideFolder)
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10),
                  child: Row(
                      // mainAxisAlignment: ResponsiveWidget.isSmallScreen(context) ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                    InkWell(
                      onTap: () async {
                        showAnimatedDialog<void>(
                            barrierDismissible: false,
                            animationType: DialogTransitionType.fadeScale,
                            duration: const Duration(milliseconds: 300),
                            context: context,
                            builder: (BuildContext context) {
                              return AddUpdateFolderDialog(
                                classroom: widget.classroom,
                              );
                            });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Themes.primaryColor,
                              Themes.secondaryColor,
                            ],
                          ),
                        ),
                        width: 127,
                        height: 30,
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.add, size: 20, color: Colors.white),
                            ),
                            Text(
                              "Add Folder",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (context.read<AppService>().isMobileDevice) {
                          await uploadHelper.pickAndUploadFileWithNotification(context: context, classroom: widget.classroom, currentUser: context.read<UserProvider>().currentUser!);
                        } else {
                          await context
                              .read<ClassroomProvider>()
                              .pickAndUploadFileAndUpdateClassroom(context: context, classroom: widget.classroom, currentUser: context.read<UserProvider>().currentUser!);
                        }
                      },
                      child: SizedBox(
                        width: 127,
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
                              const Text("Upload File"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(width: 10))),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150), // Animation duration
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // Slide animation from left to right

                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: isInsideFolder
                      ? Selector<ClassroomProvider, FolderModel?>(
                          selector: (context, provider) => provider.currentFolder,
                          builder: (context, currentFolder, child) {
                            return StreamProvider<List<FileModel>?>(
                              create: (context) => service.listenToFilesInFolder(
                                classroom: widget.classroom,
                                folderId: currentFolder?.folderId,
                                context: context,
                              ),
                              initialData: null,
                              child: Consumer<List<FileModel>?>(builder: (context, fileList, child) {
                                return FolderDetailsScreen(
                                  key: const ValueKey('FolderDetailsScreen'), // Unique key
                                  folder: currentFolder,
                                  classroom: widget.classroom,
                                  roleModel: roleModel, fileList: fileList,
                                );
                              }),
                            );
                          })
                      : widget.classroom.items == null || widget.classroom.items!.isEmpty
                          ? const Center(
                              key: ValueKey('EmptyScreen'), // Unique key
                              child: Text("No files or folders available."),
                            )
                          : ListView.builder(
                              key: const ValueKey('ListViewScreen'), // Unique key
                              //shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              controller: _scrollController,
                              itemCount: widget.classroom.items!.length,
                              itemBuilder: (context, index) {
                                final item = widget.classroom.items![index];

                                if (item.type == "file") {
                                  // Render file
                                  final file = item.file!;
                                  return FileListtile(
                                    file: file,
                                    classroom: widget.classroom,
                                    roleModel: roleModel,
                                  );
                                } else if (item.type == "folder") {
                                  // Render folder
                                  final folder = item.folder!;
                                  return FolderListtileWidget(
                                    folder: folder,
                                    classroom: widget.classroom,
                                    roleModel: roleModel,
                                    onTap: () {
                                      context.read<ClassroomProvider>().setFolder(folder);
                                      context.read<ClassroomProvider>().updateInsideFolder(true);
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink(); // Handle unexpected types
                                }
                              },
                            ),
                ),
              )
            ],
          );
        });
  }
}
