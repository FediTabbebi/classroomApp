import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/upload_helper.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/file_listtile_widget.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderDetailsScreen extends StatefulWidget {
  final FolderModel? folder;
  final List<FileModel>? fileList;
  final ClassroomModel classroom;
  final String roleModel;
  const FolderDetailsScreen({required this.folder, required this.classroom, required this.fileList, required this.roleModel, super.key});

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  late final ScrollController _scrollController;
  final uploadHelper = locator<UploadHelper>();
  ClassroomService service = locator<ClassroomService>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
        AppBarWidget(
          backgroundColor: Colors.transparent,
          withBackIcon: true,
          onTapBackIcon: () {
            context.read<ClassroomProvider>().updateInsideFolder(false);
          },
          title: widget.folder!.folderName,
          subtitle: "created by ${widget.folder!.createdBy!.firstName} ${widget.folder!.createdBy!.lastName}",
          leadingWidget: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            width: 50,
            height: 50,
            child: Icon(Icons.folder, size: 48.0, color: hexToColor(widget.folder!.colorHex)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () async {
              if (context.read<AppService>().isMobileDevice) {
                await uploadHelper.pickAndUploadFileWithNotification(
                  context: context,
                  classroom: widget.classroom,
                  currentUser: context.read<UserProvider>().currentUser!,
                  folderId: widget.folder!.folderId,
                );
              } else {
                await context
                    .read<ClassroomProvider>()
                    .pickAndUploadFileAndUpdateClassroom(context: context, classroom: widget.classroom, currentUser: context.read<UserProvider>().currentUser!, folderId: widget.folder!.folderId);
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
        ),
        Expanded(
            child: widget.fileList == null
                ? const Center(child: LoadingIndicatorWidget(size: 30))
                : widget.fileList!.isEmpty
                    ? const Center(
                        child: Text("No files available."),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        controller: _scrollController,
                        itemCount: widget.fileList!.length,
                        itemBuilder: (context, index) {
                          final file = widget.fileList![index];

                          return FileListtile(
                            folderId: widget.folder!.folderId,
                            file: file,
                            classroom: widget.classroom,
                            roleModel: widget.roleModel,
                          );
                        })),
      ],
    );
  }
}
