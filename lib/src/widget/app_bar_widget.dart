import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final IconData leadingIconData;
  final List<Widget>? actions;
  const AppBarWidget({required this.title, required this.subtitle, required this.leadingIconData, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      backgroundColor: context.read<AppService>().isMobileDevice
          ? Colors.transparent
          : context.read<ThemeProvider>().isDarkMode
              ? const Color(0xff1D1D22)
              : const Color(0xffFDFDFD),
      elevation: 0,
      leadingWidth: 80,
      titleSpacing: 0,
      leading: UnconstrainedBox(
        child: SizedBox(
          width: 40,
          height: 40,
          child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 0.2,
              color: context.watch<ThemeProvider>().isDarkMode ? const Color.fromARGB(255, 31, 28, 32) : Colors.white,
              child: Icon(
                leadingIconData,
                color: Themes.primaryColor,
              )),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
      actions: actions != null ? [if (actions!.isNotEmpty) ...actions!] : [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
