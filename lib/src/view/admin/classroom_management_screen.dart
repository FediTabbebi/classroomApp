import 'dart:math';

import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/add_update_classroom_dialog.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CLassroomManagementScreen extends StatelessWidget {
  CLassroomManagementScreen({super.key});
  final ClassroomService service = locator<ClassroomService>();
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
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
                : null),
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
                    SizedBox(
                      height: 38,
                      width: 300,
                      child: TextField(
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 1, color: Themes.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Theme.of(context).highlightColor), borderRadius: BorderRadius.circular(10)),
                          // contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                          hintText: "Search for a classroom",
                          hintStyle: const TextStyle(fontSize: 14, height: 3.5),
                        ),
                        onChanged: (value) {},
                      ),
                    ),
                    if (ResponsiveWidget.isLargeScreen(context))
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
                    return Expanded(child: buildClassroomList(data, context));
                  }
                },
              ),
            ],
          ),
        ));
  }

  Widget buildClassroomList(List<ClassroomModel> data, BuildContext context) {
    return ResponsiveWidget.isLargeScreen(context)
        ? Wrap(
            spacing: 10.0, // Horizontal spacing between cards
            runSpacing: 10.0, // Vertical spacing between rows of cards
            children: data.map((classroom) {
              return SizedBox(
                width: 300, // Fixed width
                height: 320,
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            width: 300,
                            height: 200,
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              _getAbbreviation(classroom.label),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 15,
                            child: PopupMenuButton<String>(
                              useRootNavigator: true,
                              tooltip: "Options",
                              onSelected: (value) {},
                              offset: const Offset(-150, 0),
                              itemBuilder: (ctx) => [
                                PopupMenuItem<String>(
                                  onTap: () async {
                                    showAnimatedDialog<void>(
                                        barrierDismissible: false,
                                        animationType: DialogTransitionType.fadeScale,
                                        duration: const Duration(milliseconds: 300),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddOrUpdateClassroomDialog(
                                            classroom: classroom,
                                          );
                                        });
                                  },
                                  child: const Text('Edit'),
                                ),
                                PopupMenuItem<String>(
                                  onTap: () async {
                                    showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DialogWidget(
                                          dialogTitle: "Delete confirmation",
                                          dialogContent: "Are you sure you want to delete this classroom?",
                                          isConfirmDialog: true,
                                          onConfirm: () async {
                                            Navigator.pop(context);
                                            await context.read<ClassroomProvider>().deleteClassroom(context, classroom.id);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                              child: const SizedBox(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  FontAwesomeIcons.ellipsisVertical,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 15,
                            child: classroom.invitedUsers!.isNotEmpty
                                ? Row(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 230,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: classroom.invitedUsers!.length > 4 ? classroom.invitedUsers!.sublist(0, 4).length : classroom.invitedUsers!.length,
                                          itemBuilder: (context, index) {
                                            return Tooltip(
                                              showDuration: const Duration(milliseconds: 0),
                                              message: classroom.invitedUsers![index].email,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                  color: randomColor(),
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: const EdgeInsets.only(right: 8),
                                                child: Center(
                                                  child: Text(
                                                    classroom.invitedUsers![index].email.substring(0, 2),
                                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (classroom.invitedUsers!.length > 4 && classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 4).length > 0)
                                        Tooltip(
                                          showDuration: const Duration(milliseconds: 0),
                                          message: "+"
                                              "${classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 4).length}"
                                              " member(s) is/are assigned to this project",
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            margin: const EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                "+"
                                                '${classroom.invitedUsers!.length - classroom.invitedUsers!.sublist(0, 4).length}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "This classroom has no members",
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classroom.label,
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              "${classroom.createdBy?.email}",
                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8),
                          child: Text(
                            formatDate(classroom.createdAt),
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        : ListView.separated(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final classroom = data[index];
              return ListTile(
                tileColor: Theme.of(context).dialogBackgroundColor,
                leading: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: 50,
                  color: Colors.green,
                  child: Text(
                    _getAbbreviation(classroom.label),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                title: Text(classroom.label),
                subtitle: Text("${classroom.createdBy?.email}"),
                trailing: context.read<UserProvider>().currentUser!.role == "Admin"
                    ? Wrap(
                        spacing: 15,
                        children: [
                          PopupMenuButton<String>(
                            tooltip: "Options",
                            onSelected: (value) {},
                            itemBuilder: (ctx) => [
                              PopupMenuItem<String>(
                                onTap: () async {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DialogWidget(
                                        dialogTitle: "Delete confirmation",
                                        dialogContent: "Are you sure you want to delete this classroom?",
                                        isConfirmDialog: true,
                                        onConfirm: () async {
                                          Navigator.pop(context);
                                          await context.read<ClassroomProvider>().deleteClassroom(context, classroom.id);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const Text('Delete classroom'),
                              ),
                            ],
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Icon(
                                FontAwesomeIcons.ellipsis,
                                color: Theme.of(context).highlightColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 10,
                color: Theme.of(context).highlightColor,
              );
            },
          );
  }

  String _getAbbreviation(String label) {
    // Split the label into words
    List<String> words = label.split(' ');

    if (words.length > 1) {
      // If there are multiple words, take the first letter of each
      return words[0][0] + words[1][0]; // First letter of the first word and second word
    } else {
      // If there's only one word, return the first two characters
      return label.length > 1 ? label.substring(0, 2) : label;
    }
  }

  Color randomColor() {
    Color generateRandomColor() {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    }

    Color color;
    double luminanceThreshold = 0.5;

    do {
      color = generateRandomColor();
    } while (color.computeLuminance() > luminanceThreshold);

    return color;
  }

  String formatDate(DateTime dateTime) {
    // Manually extract year, month, and day
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;

    // Format as "yyyy-MM-dd"
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
