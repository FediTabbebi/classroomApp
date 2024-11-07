import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/provider/category_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/add_update_category_dialog.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/user_management_shimmer_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  final CategoryProvider provider;
  final List<CategoryModel>? usersList;
  const CategoryManagementScreen({required this.provider, required this.usersList, super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late final FocusNode textFieldFocusNode;
  @override
  void initState() {
    textFieldFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => textFieldFocusNode.unfocus(),
      child: Scaffold(
          appBar: AppBarWidget(
            title: "Category Management Hub",
            subtitle: "Category management options are available here",
            leadingIconData: FontAwesomeIcons.tags,
            actions: [
              Tooltip(
                message: "Add Category",
                exitDuration: Duration.zero,
                child: IconButton(
                    onPressed: () {
                      showAnimatedDialog<void>(
                          barrierDismissible: false,
                          animationType: DialogTransitionType.fadeScale,
                          duration: const Duration(milliseconds: 300),
                          context: context,
                          builder: (BuildContext context) {
                            return const AddOrUpdateCategoryDialog();
                          });
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    )),
              )
            ],
          ),
          body: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
              child: SizedBox(
                height: 50,
                child: TextField(
                  focusNode: textFieldFocusNode,
                  onChanged: (value) {
                    //  timer?.cancel();
                    context.read<CategoryProvider>().filterData(value.trim());
                    // Start a new timer that calls filterData after 1 second of inactivity
                    // timer = Timer(const Duration(seconds: 1), () {
                    //   //  filterData(value, data);

                    // });
                  },
                  decoration: const InputDecoration(isDense: true, prefixIcon: Icon(Icons.search), label: Text("Search")),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            widget.usersList == null
                ? const AdminUserManagementShimmer(
                    isCategory: true,
                  )
                : widget.provider.categoriesList!.isEmpty
                    ? const Center(
                        child: Text(" There is no category "),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.provider.categoriesList!.length,
                        itemBuilder: (context, index) {
                          return customLisTileWidget(context, widget.provider.categoriesList![index], index * 100, index);
                        },
                      ),
          ])),
    );
  }

  Widget customLisTileWidget(BuildContext context, CategoryModel category, int durationDelay, int index) => Consumer<ThemeProvider>(builder: (ctx, provider, child) {
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                tileColor: Theme.of(ctx).cardTheme.color,
                leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                        child: Text(
                      "${index + 1}",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20),
                    ))),
                title: Text(
                  category.label,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "Created at ${"${category.createdAt.toLocal()}".split(' ')[0]}",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Themes.primaryColor, fontSize: 10),
                ),
                trailing: Wrap(
                  spacing: 15,
                  children: [
                    PopupMenuButton<String>(
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
                                        return AddOrUpdateCategoryDialog(
                                          category: category,
                                        );
                                      });
                                },
                              ),
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: const Text(
                                  "Delete",
                                ),
                                onTap: () async {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DialogWidget(
                                          dialogTitle: "Delete confirmation",
                                          dialogContent: "Are you sure you want to delete this Category ?",
                                          isConfirmDialog: true,
                                          onConfirm: () async {
                                            Navigator.pop(context);
                                            await context.read<CategoryProvider>().deleteCategory(context, category.id);
                                          });
                                    },
                                  );
                                },
                              ),
                            ],
                        child: Icon(
                          FontAwesomeIcons.ellipsisVertical,
                          color: Theme.of(context).highlightColor,
                          size: 20,
                        )),
                  ],
                ),
              ),
            )

            // .animate().slideX(
            //     duration: const Duration(milliseconds: 550),
            //     begin: -1,
            //     end: 0,
            //     curve: Curves.easeInOut,
            //     delay: Duration(milliseconds: durationDelay)),
            );
      });
}
