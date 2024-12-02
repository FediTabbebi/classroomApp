import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';

class ItemModel {
  final String type;
  final FileModel? file;
  final FolderModel? folder;
  final DateTime? createdAt;

  ItemModel({
    required this.type,
    this.file,
    this.folder,
    this.createdAt,
  });
}
