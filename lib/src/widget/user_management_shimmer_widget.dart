import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminUserManagementShimmer extends StatelessWidget {
  final bool? isCategory;
  const AdminUserManagementShimmer({this.isCategory, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(12, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            // isThreeLine: true,
            tileColor:
                kIsWeb ? Theme.of(context).scaffoldBackgroundColor : null,
            leading: isCategory != null
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                            color: Theme.of(context).highlightColor,
                            fontSize: 20),
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
            title: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 7.5,
                width: 150,
                color: Theme.of(context).highlightColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                UnconstrainedBox(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 7.5,
                    width: 200,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                UnconstrainedBox(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 5,
                    width: 100,
                    color: Theme.of(context).highlightColor,
                  ),
                )
              ],
            ),
            trailing: Icon(
              FontAwesomeIcons.ellipsisVertical,
              color: Theme.of(context).highlightColor,
            ),
          ),
        );
      }),
    );
  }
}
