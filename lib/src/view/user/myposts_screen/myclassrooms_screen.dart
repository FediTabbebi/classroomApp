import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/classroom_card_widget.dart';
import 'package:classroom_app/src/widget/classroom_listitle_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyClassroomsScreen extends StatefulWidget {
  const MyClassroomsScreen({super.key});

  @override
  State<MyClassroomsScreen> createState() => _MyClassroomsScreenState();
}

class _MyClassroomsScreenState extends State<MyClassroomsScreen> {
  final ClassroomService service = locator<ClassroomService>();
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
          appBar: const AppBarWidget(
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
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                        hintText: "Search for a classroom",
                        hintStyle: const TextStyle(fontSize: 14),
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
                              : buildClassroomList(data, context));
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
        ? Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: data.map((classroom) {
              return ClassroomCardWidget(classroom: classroom);
            }).toList(),
          )
        : ListView.separated(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final classroom = data[index];
              return ClassroomListitleWidget(classroom: classroom);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
          );
  }
}
