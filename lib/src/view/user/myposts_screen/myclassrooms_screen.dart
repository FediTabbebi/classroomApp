import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyClassroomsScreen extends StatelessWidget {
  MyClassroomsScreen({super.key});
  final ClassroomService service = locator<ClassroomService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
              Consumer<List<ClassroomModel>?>(
                builder: (context, data, child) {
                  if (data == null) {
                    return const Center(
                      child: LoadingIndicatorWidget(
                        size: 40,
                      ),
                    );
                  } else if (data.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text("There is no available classrooms for the moment"),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          print(index);
                          return ListTile(
                            tileColor: Theme.of(context).dialogBackgroundColor,
                            leading: Container(
                              height: 50,
                              width: 50,
                              color: Colors.green,
                              child: Center(child: Text(data[index].label.substring(0, 2))),
                            ),
                            title: Text(data[index].label),
                            subtitle: Text("${data[index].createdBy?.email}"),
                          );

                          //    PostListTileWidget(classroom: data[index], createdBy: data[index].createdBy!, index: index);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 10,
                            color: Theme.of(context).highlightColor,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ));
  }
}
