import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIconData;
  final Widget? leadingWidget;
  final bool withBackIcon;
  final Color? backgroundColor;
  final void Function()? onTapBackIcon;
  final List<Widget>? actions;
  const AppBarWidget(
      {required this.title, this.leadingWidget, this.onTapBackIcon, this.backgroundColor, this.withBackIcon = false, required this.subtitle, this.leadingIconData, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? (context.read<AppService>().isMobileDevice ? Colors.transparent : Theme.of(context).cardTheme.color),
      elevation: 0,
      leadingWidth: withBackIcon
          ? leadingWidget != null
              ? 125
              : 100
          : 80,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withBackIcon)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: onTapBackIcon ??
                      () {
                        context.pop();
                      },
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Icon(
                    Icons.arrow_back_sharp,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    size: 25,
                  ),
                ),
              ),
            UnconstrainedBox(
              child: leadingWidget ??
                  SizedBox(
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
          ],
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
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
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
