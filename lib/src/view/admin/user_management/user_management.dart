import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/view/admin/user_management/user_management_datasource.dart';
import 'package:classroom_app/src/widget/add_update_user_dialog.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/src/widget/user_listtile_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserManagementScreen extends StatefulWidget {
  final List<UserModel>? usersList;
  const UserManagementScreen({required this.usersList, super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late TextEditingController searchController;
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  String searchQuery = '';
  double headerHeight = 80;
  double dataPagerHeight = 80;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBarWidget(
              title: "User Management Hub",
              subtitle: "User management options are available here",
              leadingIconData: FontAwesomeIcons.users,
              actions: !ResponsiveWidget.isLargeScreen(context)
                  ? [
                      Tooltip(
                        message: "Add user",
                        exitDuration: Duration.zero,
                        child: IconButton(
                            onPressed: () {
                              showAnimatedDialog<void>(
                                  barrierDismissible: false,
                                  animationType: DialogTransitionType.fadeScale,
                                  duration: const Duration(milliseconds: 300),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AddOrUpdateUserDialog();
                                  });
                            },
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            )),
                      )
                    ]
                  : null),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: 45,
                          width: ResponsiveWidget.isLargeScreen(context) ? 300 : double.infinity,
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(width: 1, color: Themes.primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Theme.of(context).highlightColor), borderRadius: BorderRadius.circular(10)),
                              // contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.darkGrey,
                              ),
                              hintText: "Search for a user",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                              ),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 20,
                                        color: AppColors.darkGrey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                          searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                      if (ResponsiveWidget.isLargeScreen(context))
                        Tooltip(
                          message: "Add user",
                          exitDuration: Duration.zero,
                          child: ElevatedButtonWidget(
                              radius: 6,
                              height: 43,
                              width: 100,
                              onPressed: () {
                                showAnimatedDialog<void>(
                                    barrierDismissible: false,
                                    animationType: DialogTransitionType.fadeScale,
                                    duration: const Duration(milliseconds: 300),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AddOrUpdateUserDialog();
                                    });
                              },
                              text: "Add user"),
                        )
                    ],
                  ),
                ),
                widget.usersList == null
                    ? Expanded(
                        child: Center(
                            child: LoadingIndicatorWidget(
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      )
                    : widget.usersList!.isEmpty
                        ? const Expanded(
                            child: Center(
                            child: Text("There is no user other than you in this platform"),
                          ))
                        : Selector<UserProvider, List<UserModel>?>(
                            selector: (context, provider) => provider.userModelList,
                            builder: (context, usersList, child) {
                              // Filter users based on search query
                              List<UserModel> filteredUsers = usersList!.where((user) {
                                // Combine email, first name, and last name into one search scope
                                String userDetails = [
                                  user.email,
                                  user.firstName,
                                  user.lastName,
                                ].join(' ').toLowerCase();

                                // Check if the search query matches any part of the user details
                                return userDetails.contains(searchQuery.toLowerCase());
                              }).toList();

                              // Update the data source for the user management
                              context.read<UserProvider>().userManagementDataSource = UserManagementDatasource(
                                users: filteredUsers,
                                context: context,
                              );

                              // Display filtered results or fallback if none match
                              return filteredUsers.isEmpty
                                  ? const Expanded(
                                      child: Center(
                                        child: Text("There is no user that matches your search."),
                                      ),
                                    )
                                  : ResponsiveWidget.isLargeScreen(context)
                                      ? largeScreen(filteredUsers)
                                      : smallScreen(filteredUsers);
                            },
                          )
              ],
            ),
          )),
    );
  }

  Widget smallScreen(List<UserModel> filteredUsers) {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          return UserListtileWidget(
            user: filteredUsers[index],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }

  Widget largeScreen(List<UserModel> filteredUsers) {
    return Container(
      // alignment: Alignment.center,
      // margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: !context.read<ThemeProvider>().isDarkMode ? Border.all(color: Theme.of(context).highlightColor) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSfDataGrid(
            context: context,
            userManagementDataSource: context.read<UserProvider>().userManagementDataSource!,
            dataPagerHeight: dataPagerHeight,
            headerHeight: headerHeight,
          ),
          buildSfDataPager(
            dataPagerHeight: dataPagerHeight,
            context: context,
            userManagementDataSource: context.read<UserProvider>().userManagementDataSource!,
            users: filteredUsers,
          )
        ],
      ),
    );
  }

  Widget buildSfDataPager({
    required double dataPagerHeight,
    required BuildContext context,
    required UserManagementDatasource userManagementDataSource,
    required List<UserModel> users,
  }) {
    return SfDataPagerTheme(
      data: SfDataPagerThemeData(
          disabledItemColor: Theme.of(context).hoverColor,
          selectedItemTextStyle: const TextStyle(color: Colors.white),
          itemBorderWidth: 0.5,
          itemBorderColor: Theme.of(context).highlightColor,
          itemBorderRadius: BorderRadius.circular(5),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          itemColor: Theme.of(context).colorScheme.surface,
          itemTextStyle: Theme.of(context).textTheme.bodySmall!),
      child: SfDataPager(
        itemHeight: 47,
        itemWidth: 50,
        navigationItemWidth: 100,
        delegate: userManagementDataSource,
        visibleItemsCount: 5,
        direction: Axis.horizontal,
        initialPageIndex: 1,
        lastPageItemVisible: false,
        firstPageItemVisible: false,
        pageCount: users.isEmpty ? 1 : (users.length / 5).ceil().toDouble(),
        pageItemBuilder: (String itemName) {
          if (itemName == 'Next') {
            return const Text(
              "Next",
              style: TextStyle(fontSize: 14),
            );
          }
          if (itemName == 'Previous') {
            return const Text(
              "Previous",
              style: TextStyle(fontSize: 14),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget buildSfDataGrid({
    required BuildContext context,
    required UserManagementDatasource userManagementDataSource,
    required double dataPagerHeight,
    required double headerHeight,
  }) {
    return Container(
      //  margin: const EdgeInsetsDirectional.symmetric(vertical: 40),
      // height: MediaQuery.sizeOf(context).height - (dataPagerHeight + 167),
      //  width: MediaQuery.sizeOf(context).width,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height - (dataPagerHeight + 145),
      ),
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          headerHoverColor: context.read<ThemeProvider>().isDarkMode ? const Color(0xff1D1D22) : const Color(0xffFDFDFD),
          rowHoverColor: Theme.of(context).hoverColor,
          // headerColor: context.read<ThemeProvider>().isDarkMode ? Theme.of(context).highlightColor.withOpacity(0.02) : const Color(0xffFAFBFD),
          sortIconColor: Theme.of(context).colorScheme.primary,
          filterIconColor: Theme.of(context).colorScheme.primary,
          gridLineColor: Theme.of(context).hintColor,
          sortIcon: Builder(
            builder: (context) {
              Widget? icon;
              String columnName = '';
              context.visitAncestorElements((element) {
                if (element is GridHeaderCellElement) {
                  columnName = element.column.columnName;
                }
                return true;
              });
              var column = userManagementDataSource.sortedColumns.where((element) => element.name == columnName).firstOrNull;
              if (column != null) {
                if (column.sortDirection == DataGridSortDirection.ascending) {
                  icon = Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      FaIcon(
                        FontAwesomeIcons.sortDown,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
                      ),
                    ],
                  );
                } else if (column.sortDirection == DataGridSortDirection.descending) {
                  icon = Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
                      ),
                      FaIcon(FontAwesomeIcons.sortDown, size: 16, color: Theme.of(context).textTheme.bodyLarge!.color!),
                    ],
                  );
                }
              }
              return icon ??
                  FaIcon(
                    FontAwesomeIcons.sort,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
                  );
            },
          ),
        ),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SfDataGrid(
            headerRowHeight: 70,
            shrinkWrapRows: true,
            source: userManagementDataSource,
            showVerticalScrollbar: true,
            showHorizontalScrollbar: false,
            isScrollbarAlwaysShown: true,
            columnWidthMode: ColumnWidthMode.fill,
            showColumnHeaderIconOnHover: false,
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            navigationMode: GridNavigationMode.row,
            selectionMode: SelectionMode.none,
            allowSorting: true,
            allowTriStateSorting: true,
            allowMultiColumnSorting: true,
            showSortNumbers: true,
            rowsPerPage: 10,
            rowHeight: 80,
            columns: <GridColumn>[
              GridColumn(
                columnName: 'user',
                minimumWidth: 160,
                label: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "User",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                  ),
                ),
              ),
              GridColumn(
                columnName: 'memberSince',
                width: 160,
                visible: true,
                label: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Member since",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                  ),
                ),
              ),
              GridColumn(
                columnName: 'role',
                width: 160,
                label: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Role",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                  ),
                ),
              ),
              GridColumn(
                columnName: 'status',
                width: 160,
                label: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  //  alignment: Alignment.center,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Status",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                  ),
                ),
              ),
              GridColumn(
                width: 160,
                allowSorting: false,
                columnName: 'actions',
                label: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Actions",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
