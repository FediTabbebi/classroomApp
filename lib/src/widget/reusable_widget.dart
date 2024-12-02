import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/src/widget/add_update_user_dialog.dart';
import 'package:classroom_app/src/widget/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

Widget menuWidget(BuildContext context, UserModel user) => MenuAnchor(
        alignmentOffset: const Offset(-120, -30),
        builder: (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(
                FontAwesomeIcons.ellipsisVertical,
                size: 24,
              ),
              tooltip: "Options");
        },
        menuChildren: [
          MenuItemButton(
            onPressed: () async {
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
            leadingIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  FontAwesomeIcons.pen,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                )),
            child: const Text(
              "Edit",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          MenuItemButton(
            onPressed: () async {
              showDialog<void>(
                context: context,
                builder: (BuildContext ctx) {
                  return DialogWidget(
                    dialogTitle: user.isDeleted ? "Unban Confirmation" : "Ban Confirmation",
                    dialogContent: user.isDeleted ? "Are you sure you want to unban this user?" : "Are you sure you want to ban this user?",
                    isConfirmDialog: true,
                    onConfirm: () async {
                      Navigator.pop(ctx);
                      await context.read<UpdateUserProvider>().banOrUnbanUser(context, user, user.role!.id);
                    },
                  );
                },
              );
            },
            leadingIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  user.isDeleted ? FontAwesomeIcons.recycle : FontAwesomeIcons.ban,
                  color: user.isDeleted ? Colors.green : Colors.red,
                  size: 20,
                )),
            child: SizedBox(
              width: 100,
              child: Text(
                user.isDeleted ? " Unban" : "Ban",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ]);
