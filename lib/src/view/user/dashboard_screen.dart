import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/provider/user/dashboard_provider.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/utils/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Dashboard",
        subtitle: "Here you will find all your assignee work",
        leadingIconData: FontAwesomeIcons.sheetPlastic,
      ),
      body: Selector<DashboardProvider, int>(
          selector: (context, provider) => provider.currentIndex,
          builder: (context, currentIndex, child) {
            return Column(
              children: [
                Row(
                  children: [
                    navBarItem(
                      context: context,
                      title: "Discussion",
                      currentIndex: currentIndex,
                      index: 1,
                      onTap: () {
                        context.read<DashboardProvider>().updatePageIndex(1);
                      },
                    ),
                    navBarItem(
                      context: context,
                      title: "Files",
                      currentIndex: currentIndex,
                      index: 2,
                      onTap: () {
                        context.read<DashboardProvider>().updatePageIndex(2);
                      },
                    ),
                  ].divide(const SizedBox(
                    width: 5,
                  )),
                ),
                Expanded(
                  child: IndexedStack(
                    // textDirection: TextDirection.rtl,
                    sizing: StackFit.expand,
                    index: currentIndex - 1,
                    children: const [
                      SizedBox(
                        child: Center(child: Text("Chat page")),
                      ),
                      //AllPostsScreen(),
                      SizedBox(
                        child: Center(child: Text("files page")),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: currentIndex == index ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).hintColor),
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
