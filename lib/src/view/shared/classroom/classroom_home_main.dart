import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/view/shared/classroom/chat_screen.dart';
import 'package:classroom_app/src/view/shared/classroom/files_screen.dart';
import 'package:classroom_app/src/view/shared/classroom/members_screen.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/utils/extension_helper.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ClassroomHomeMain extends StatefulWidget {
  final String classroomId;

  const ClassroomHomeMain({required this.classroomId, super.key});

  @override
  State<ClassroomHomeMain> createState() => _ClassroomHomeMainState();
}

class _ClassroomHomeMainState extends State<ClassroomHomeMain> {
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    if (context.read<ClassroomProvider>().currentIndex != 1) {
      context.read<ClassroomProvider>().currentIndex = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data = context.watch<List<ClassroomModel>?>();
    if (data != null) {
      final classroomExists = data.any((e) => e.id == widget.classroomId);
      if (!classroomExists && !_isExiting) {
        _isExiting = true; // Prevent multiple pops
        Future.microtask(() {
          if (mounted) {
            context.pop(); // Exit the screen
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ClassroomProvider, List<ClassroomModel>?>(
      builder: (context, provider, data, child) {
        final data = context.watch<List<ClassroomModel>?>();
        if (_isExiting || data == null || !data.any((e) => e.id == widget.classroomId)) {
          return const SizedBox.shrink(); // Render nothing while exiting
        } else {
          final classroom = data.firstWhere((e) => e.id == widget.classroomId);
          return Column(
            children: [
              AppBarWidget(
                withBackIcon: true,
                title: classroom.label,
                subtitle: "Classroom Details",
                leadingWidget: Container(
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: hexToColor(classroom.colorHex), borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    // classroom.label,
                    getAbbreviation(classroom.label),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              Row(
                children: [
                  navBarItem(
                    context: context,
                    title: "Discussion",
                    currentIndex: provider.currentIndex,
                    index: 1,
                    onTap: () {
                      provider.updatePageIndex(1);
                    },
                  ),
                  navBarItem(
                    context: context,
                    title: "Files",
                    currentIndex: provider.currentIndex,
                    index: 2,
                    onTap: () {
                      if (FocusScope.of(context).hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                      provider.updatePageIndex(2);
                    },
                  ),
                  navBarItem(
                    context: context,
                    title: "Members",
                    currentIndex: provider.currentIndex,
                    index: 3,
                    onTap: () {
                      if (FocusScope.of(context).hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                      provider.updatePageIndex(3);
                    },
                  ),
                ].divide(const SizedBox(width: 5)),
              ),
              Expanded(
                child: IndexedStack(
                  sizing: StackFit.expand,
                  index: provider.currentIndex - 1,
                  children: [
                    ChatScreen(classroom: classroom),
                    FilesScreen(classroom: classroom),
                    MembersScreen(classroom: classroom),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget navBarItem({required BuildContext context, required String title, required int currentIndex, required int index, required Function() onTap, int? itemLength}) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(border: index == currentIndex ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null),
            child: InkWell(
              onTap: onTap,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: currentIndex == index ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    if (itemLength != null)
                      const SizedBox(
                        width: 10,
                      ),
                    if (itemLength != null)
                      Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == index
                                ? context.read<ThemeProvider>().isDarkMode
                                    ? Colors.white
                                    : const Color(0xffF5F6FA)
                                : Colors.grey.withOpacity(0.1)),
                        child: Text(
                          "$itemLength",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: currentIndex == index
                                  ? Colors.black
                                  : context.read<ThemeProvider>().isDarkMode
                                      ? Colors.white
                                      : Colors.grey),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}
