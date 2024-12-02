import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/classroom_card_widget.dart';
import 'package:classroom_app/src/view/shared/classroom/widget/classroom_listitle_widget.dart';
import 'package:classroom_app/src/widget/add_update_classroom_dialog.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AllClassroomsScreen extends StatefulWidget {
  const AllClassroomsScreen({super.key});

  @override
  State<AllClassroomsScreen> createState() => _AllClassroomsScreenState();
}

class _AllClassroomsScreenState extends State<AllClassroomsScreen> {
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: context.read<UserProvider>().currentUser!.role!.id != "3"
              ? AppBarWidget(
                  title: "Classroom Management Hub",
                  subtitle: "classroom management options are available here",
                  leadingIconData: FontAwesomeIcons.sheetPlastic,
                  actions: !ResponsiveWidget.isLargeScreen(context)
                      ? [
                          Tooltip(
                            message: "Add Classroom",
                            exitDuration: Duration.zero,
                            child: IconButton(
                                onPressed: () {
                                  showAnimatedDialog<void>(
                                      barrierDismissible: false,
                                      animationType: DialogTransitionType.fadeScale,
                                      duration: const Duration(milliseconds: 300),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AddOrUpdateClassroomDialog();
                                      });
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                )),
                          )
                        ]
                      : null)
              : const AppBarWidget(
                  title: "Classroom Hub",
                  subtitle: "Here you will find all the classrooms you've been invited in",
                  leadingIconData: FontAwesomeIcons.sheetPlastic,
                ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              prefixIcon: const Icon(Icons.search, color: AppColors.darkGrey),
                              hintText: "Search for a classroom",
                              hintStyle: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 20,
                                        color: Color(0xff667085),
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
                      if (ResponsiveWidget.isLargeScreen(context) && context.read<UserProvider>().currentUser!.role!.id != "3")
                        Tooltip(
                          message: "Add classroom",
                          exitDuration: Duration.zero,
                          child: ElevatedButtonWidget(
                              radius: 6,
                              height: 43,
                              width: 150,
                              onPressed: () {
                                showAnimatedDialog<void>(
                                    barrierDismissible: false,
                                    animationType: DialogTransitionType.fadeScale,
                                    duration: const Duration(milliseconds: 300),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AddOrUpdateClassroomDialog();
                                    });
                              },
                              text: "Add classroom"),
                        )
                    ],
                  ),
                ),
                Consumer<List<ClassroomModel>?>(
                  builder: (context, data, child) {
                    if (data == null) {
                      return const Expanded(
                        child: Center(
                          child: LoadingIndicatorWidget(
                            size: 40,
                          ),
                        ),
                      );
                    } else if (data.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text("There is no available classrooms for the moment"),
                        ),
                      );
                    } else {
                      List<ClassroomModel> filetredClassrooms = data.where((classroom) {
                        final filtred = data.firstWhere((searchedClassRoom) => searchedClassRoom.label == classroom.label,
                            orElse: () => ClassroomModel(id: "", label: "", colorHex: "", createdByRef: classroom.createdByRef, createdAt: classroom.createdAt, updatedAt: classroom.updatedAt));
                        if (filtred.id == '') {
                          return false;
                        }
                        String classroomLabel = filtred.label.toLowerCase();
                        return classroomLabel.contains(searchQuery.toLowerCase());
                      }).toList();
                      return Expanded(
                          child: filetredClassrooms.isEmpty
                              ? const Center(
                                  child: Text("There is no classroom match this name"),
                                )
                              : buildClassroomList(filetredClassrooms, context));
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }

  Widget buildClassroomList(List<ClassroomModel> data, BuildContext context) {
    return ResponsiveWidget.isLargeScreen(context)
        ? SingleChildScrollView(
            child: Wrap(
              spacing: 1.0,
              runSpacing: 10.0,
              children: data.map((classroom) {
                return ClassroomCardWidget(
                  classroom: classroom,
                  onTap: () {
                    if (context.read<UserProvider>().currentUser!.role!.id == "1") {
                      context.pushNamed("admin-classroom-details", pathParameters: {"classroomId": classroom.id});
                    } else if (context.read<UserProvider>().currentUser!.role!.id == "2") {
                      context.pushNamed("instructor-classroom-details", pathParameters: {"classroomId": classroom.id});
                    } else {
                      context.pushNamed("user-classroom-details", pathParameters: {"classroomId": classroom.id});
                    }
                  },
                );
              }).toList(),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final classroom = data[index];
              return ClassroomListitleWidget(
                classroom: classroom,
                onTap: () {
                  if (context.read<UserProvider>().currentUser!.role!.id == "1") {
                    context.pushNamed("admin-classroom-details", pathParameters: {"classroomId": classroom.id});
                  } else if (context.read<UserProvider>().currentUser!.role!.id == "2") {
                    context.pushNamed("instructor-classroom-details", pathParameters: {"classroomId": classroom.id});
                  } else {
                    context.pushNamed("user-classroom-details", pathParameters: {"classroomId": classroom.id});
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
          );
  }
}
