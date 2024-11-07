import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/model/post_model.dart';
import 'package:classroom_app/provider/category_provider.dart';
import 'package:classroom_app/service/post_service.dart';
import 'package:classroom_app/src/view/user/post_screen/widget/filter_category_widget.dart';
import 'package:classroom_app/src/view/user/post_screen/widget/post_listtile_widget.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PostManagementScreen extends StatelessWidget {
  PostManagementScreen({super.key});
  final PostService service = locator<PostService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "All Posts ",
          subtitle: "Posts management hub",
          leadingIconData: FontAwesomeIcons.envelopesBulk,
          actions: [
            Tooltip(
              message: "Filter post",
              child: SizedBox(
                  width: 90,
                  height: 80,
                  child: FilterCategoryWidget(
                    isAdmin: true,
                  )),
            ),
          ],
        ),
        body: Consumer2<List<PostModel>?, CategoryProvider>(
          builder: (context, data, provider, child) {
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
                  children: [Text("There is no one posting for the moment")],
                ),
              );
            } else {
              List<PostModel> filteredList = filterPostsByCategory(data, provider.adminSelectedCategories);
              if (filteredList.isEmpty) {
                return const Center(
                    child: Text(
                  "There is no post that match this category",
                  textAlign: TextAlign.center,
                ));
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    print(index);
                    return PostListTileWidget(post: filteredList[index], createdBy: filteredList[index].createdBy!, index: index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 10,
                      color: Theme.of(context).highlightColor,
                    );
                  },
                );
              }
            }
          },
        ));
  }

  List<PostModel> filterPostsByCategory(List<PostModel> data, List<CategoryModel> selectedCategories) {
    if (selectedCategories.isEmpty) {
      return data;
    }
    return data.where((post) {
      String postCategoryId = post.category.id;
      return selectedCategories.any((selectedCategory) => selectedCategory.id == postCategoryId);
    }).toList();
  }
}
