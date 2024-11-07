import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminUserManagementShimmer extends StatelessWidget {
  final bool? isCategory;
  const AdminUserManagementShimmer({this.isCategory, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(
        children: [
          Center(
            child: Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(width: 0.5, color: Colors.grey),
                ),
                columnWidths: ResponsiveWidget.isLargeScreen(context)
                    ? {
                        0: FixedColumnWidth(MediaQuery.of(context).size.width / 5.5),
                        1: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
                        2: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
                        3: FixedColumnWidth(MediaQuery.of(context).size.width / 10),
                        4: FixedColumnWidth(MediaQuery.of(context).size.width / 8),
                      }
                    : kIsWeb
                        ? {
                            0: FixedColumnWidth(MediaQuery.of(context).size.width / 1.3),
                          }
                        : ResponsiveWidget.isMediumScreen(context)
                            ? {
                                0: FixedColumnWidth(MediaQuery.of(context).size.width / 1.5),
                              }
                            : {
                                0: FixedColumnWidth(MediaQuery.of(context).size.width),
                              },
                children: [
                  ...getTableRows(context),
                  ...List.generate(12, (index) {
                    return TableRow(children: getTableCells(context));
                  }),
                ]),
          ),
        ],
      ),
    );
  }

  Widget tableHeaderRow(String title, bool end, bool middle) {
    return TableCell(
        child: Text(title,
            style: const TextStyle(color: Colors.grey),
            textAlign: middle
                ? TextAlign.center
                : end
                    ? TextAlign.end
                    : TextAlign.start));
  }

  List<TableRow> getTableRows(BuildContext context) {
    if (ResponsiveWidget.isLargeScreen(context)) {
      return [
        TableRow(
          children: [
            tableHeaderRow("User", false, false),
            tableHeaderRow("Member Since", false, false),
            tableHeaderRow("Role", false, false),
            tableHeaderRow("Status", true, false),
            tableHeaderRow("Options", true, ResponsiveWidget.isLargeScreen(context) ? true : false),
          ],
        ),
      ];
    } else {
      return [
        TableRow(
          children: [
            tableHeaderRow("", false, true),
          ],
        ),
      ];
    }
  }

  List<TableCell> getTableCells(BuildContext context) {
    if (ResponsiveWidget.isLargeScreen(context)) {
      return [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ListTile(
                tileColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
                title: Container(
                  height: 7.5,
                  color: Colors.grey,
                ),
                subtitle: Container(
                  height: 7.5,
                  color: Colors.grey,
                ),
              ),
            )),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  height: 10,
                  width: 80,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 10,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 10,
                  width: 50,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        )
      ];
    } else {
      return [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: ListTile(
                // isThreeLine: true,
                tileColor: kIsWeb ? Theme.of(context).scaffoldBackgroundColor : null,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
                title: UnconstrainedBox(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 7.5,
                    width: 150,
                    color: Colors.grey,
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
                        color: Colors.grey,
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
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                trailing: const Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Colors.grey,
                ),
              ),
            ))
      ];
    }
  }
}
