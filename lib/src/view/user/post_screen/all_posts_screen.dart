import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/service/classroom_service.dart';
import 'package:classroom_app/src/view/user/post_screen/widget/post_listtile_widget.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AllClassroomScreen extends StatelessWidget {
  AllClassroomScreen({super.key});
  final ClassroomService service = locator<ClassroomService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "All Posts ",
          subtitle: "Posts are available here",
          leadingIconData: FontAwesomeIcons.envelopesBulk,
        ),
        body: Consumer<List<ClassroomModel>?>(
          builder: (context, data, child) {
            if (data == null) {
              return Column(
                  children: List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: CustomPostListTileShimmer(),
                ),
              ));
            } else if (data.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("There is no classrooms yet")],
                ),
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return PostListTileWidget(classroom: data[index], createdBy: data[index].createdBy!, index: index);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 10,
                    color: Theme.of(context).highlightColor,
                  );
                },
              );
            }
          },
        ));
  }
}
