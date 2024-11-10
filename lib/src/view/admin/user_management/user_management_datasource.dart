import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/src/widget/add_update_user_dialog.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserManagementDatasource extends DataGridSource {
  final BuildContext context;
  final List<UserModel> users;

  int rowsPerPage;
  late List<UserModel> paginatedUsers;

  UserManagementDatasource({
    required this.users,
    required this.context,
    this.rowsPerPage = 5,
  }) {
    paginatedUsers = users.length < rowsPerPage ? users.getRange(0, users.length).toList(growable: false) : users.getRange(0, rowsPerPage).toList(growable: false);
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];
  UserModel? selectedUser;
  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Theme.of(context).colorScheme.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        final user = paginatedUsers[dataGridRows.indexOf(row)];
        if (dataGridCell.columnName == 'actions') {
          return Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PopupMenuButton<String>(
                tooltip: "Options",
                onSelected: (value) {},
                itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'Edit',
                        child: const Text('Edit'),
                        onTap: () {
                          showAnimatedDialog<void>(
                              barrierDismissible: false,
                              animationType: DialogTransitionType.fadeScale,
                              duration: const Duration(milliseconds: 300),
                              context: context,
                              builder: (BuildContext context) {
                                return AddOrUpdateUserDialog(
                                  user: user,
                                );
                              });
                        },
                      ),
                      PopupMenuItem<String>(
                        value: 'Ban',
                        child: Text(
                          user.isDeleted ? " Unban" : "ban",
                        ),
                        onTap: () async {
                          await context.read<UpdateUserProvider>().banOrUnbanUser(context, user);
                        },
                      ),
                    ],
                child: Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Theme.of(context).highlightColor,
                  size: 20,
                )),
          );
        } else if (dataGridCell.columnName == 'user') {
          return Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                user.profilePicture.isEmpty
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: Image.asset(AppImages.userProfile).image, fit: BoxFit.cover),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: user.profilePicture,
                        alignment: Alignment.center,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                            margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(color: Theme.of(context).hoverColor, shape: BoxShape.circle),
                            child: const Center(
                                child: LoadingIndicatorWidget(
                              size: 30,
                            ))),
                        errorWidget: (context, url, error) => Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(image: Image.asset("assets/images/user_holder.png").image, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                const SizedBox(width: 10), // Add spacing between image and text
                Expanded(
                    child: Text("${user.firstName} ${user.lastName}",
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
          );
        } else if (dataGridCell.columnName == 'status') {
          return Container(
            padding: const EdgeInsetsDirectional.only(start: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dataGridCell.value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: dataGridCell.value == "Banned" ? Colors.red : Colors.green),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsetsDirectional.only(start: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dataGridCell.value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startIndex = newPageIndex * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    if (startIndex < users.length) {
      if (endIndex > users.length) {
        endIndex = users.length;
      }
      paginatedUsers = users.getRange(startIndex, endIndex).toList(growable: false);
      buildDataGridRows();
    } else {
      paginatedUsers = [];
    }
    notifyListeners();
    return true;
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  void buildDataGridRows() {
    dataGridRows = paginatedUsers
        .map<DataGridRow>((dataGridRow) => DataGridRow(
              cells: [
                DataGridCell<UserModel>(columnName: 'user', value: dataGridRow),
                DataGridCell<String>(
                  columnName: 'memberSince',
                  value: "${dataGridRow.createdAt.toLocal()}".split(' ')[0],
                ),
                DataGridCell<String>(columnName: 'role', value: dataGridRow.role),
                DataGridCell<String>(
                  columnName: 'status',
                  value: dataGridRow.isDeleted ? "Banned" : "Active",
                ),
                DataGridCell<Icon>(
                  columnName: 'actions',
                  value: Icon(
                    FontAwesomeIcons.ellipsis,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ))
        .toList(growable: false);
  }
}
