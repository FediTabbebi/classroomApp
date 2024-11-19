import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/provider/classroom_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/view/shared/classroom/classroom_details_screen.dart';
import 'package:classroom_app/src/view/shared/classroom/files_screen.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/utils/extension_helper.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassroomHomeMain extends StatefulWidget {
  final String classroomId;

  const ClassroomHomeMain({required this.classroomId, super.key});

  @override
  State<ClassroomHomeMain> createState() => _ClassroomHomeMainState();
}

class _ClassroomHomeMainState extends State<ClassroomHomeMain> {
  @override
  void initState() {
    super.initState();
    if (context.read<ClassroomProvider>().currentIndex != 1) {
      context.read<ClassroomProvider>().currentIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ClassroomProvider, List<ClassroomModel>?>(
      builder: (context, provider, data, child) {
        if (data == null) {
          return Center(
            child: LoadingIndicatorWidget(
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
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
                ].divide(const SizedBox(width: 5)),
              ),
              Expanded(
                child: IndexedStack(
                  sizing: StackFit.expand,
                  index: provider.currentIndex - 1,
                  children: [
                    ClassroomDetailsScreen(classroom: classroom),
                    FilesScreen(classroom: classroom),
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
