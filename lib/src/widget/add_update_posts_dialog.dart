import 'package:classroom_app/locator.dart';
import 'package:classroom_app/model/category_model.dart';
import 'package:classroom_app/model/post_model.dart';
import 'package:classroom_app/provider/category_provider.dart';
import 'package:classroom_app/provider/post_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/service/categories_service.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AddOrUpdatePostDialog extends StatefulWidget {
  final CategoryModel? post;
  const AddOrUpdatePostDialog({this.post, super.key});

  @override
  State<AddOrUpdatePostDialog> createState() => _AddOrUpdateUserDialogState();
}

class _AddOrUpdateUserDialogState extends State<AddOrUpdatePostDialog> {
  CategoriesService service = locator<CategoriesService>();
  @override
  void initState() {
    super.initState();
    context.read<PostProvider>().clearControllers();
    context.read<PostProvider>().isSelectFromAllCategories = false;
    if (widget.post != null) {
      //context.read<CategoryProvider>().initControllers(widget.post!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Form(
          key: context.read<PostProvider>().postFormKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.read<CategoryProvider>().clearControllers();
                      },
                      child: Icon(
                        size: 20,
                        FontAwesomeIcons.xmark,
                        color: Theme.of(context).hintColor,
                      ),
                    )),
                Text(
                  widget.post != null ? "Update Post" : " Create Post",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "Post Category",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Consumer<PostProvider>(builder: (context, provider, child) {
                  return Column(
                    children: [
                      provider.isSelectFromAllCategories
                          ? textFieldWidget(
                              hintText: "Add a category",
                              textEditingController: context.read<PostProvider>().postCategoryController,
                              validator: (value) => validateEmptyField(
                                    value!,
                                  ),
                              context: context)
                          : Container(
                              constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
                              child: DropdownSearch<CategoryModel>(
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                    baseStyle: const TextStyle(fontSize: 12),
                                    dropdownSearchDecoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        isDense: true,
                                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(5.0)),
                                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                        focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                        fillColor: Theme.of(context).cardTheme.color,
                                        errorStyle: const TextStyle(
                                          height: 1,
                                          fontSize: 12,
                                        ),
                                        hintStyle: const TextStyle(
                                          height: 1,
                                          fontSize: 12,
                                        ),
                                        hintText: "Select a category for your post")),
                                key: context.read<PostProvider>().postMultiKey,
                                asyncItems: (String? filter) => service.getCategories(),
                                itemAsString: (item) {
                                  return item.label;
                                },
                                onChanged: (category) {
                                  context.read<PostProvider>().selectedCategory = category;
                                },
                                selectedItem: widget.post,
                                validator: (value) => validateEmptyFieldWithResponse(value?.label, "Please select post's category or add one"),
                                popupProps: PopupProps.menu(
                                  errorBuilder: (context, searchEntry, exception) {
                                    return const Center(
                                        child: Text(
                                      "An error has occured when fetching categories",
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ));
                                  },
                                  emptyBuilder: (context, searchEntry) {
                                    return const Center(
                                        child: Text(
                                      "It seems like there is no category\n You can add one by pressing on the button down below ",
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ));
                                  },
                                  loadingBuilder: (context, searchEntry) {
                                    return const Center(
                                        child: Text(
                                      "Fetching categories ...",
                                      style: TextStyle(fontSize: 14),
                                    ));
                                  },
                                  itemBuilder: (context, item, isSelected) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                  constraints: const BoxConstraints(minHeight: 35, maxHeight: 210),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Align(
                      //     alignment: Alignment.bottomRight,
                      //     child: InkWell(
                      //       onTap: () {
                      //         provider.updateCategorySelection();
                      //       },
                      //       child: Text(
                      //         provider.isSelectFromAllCategories
                      //             ? "Select from all categories"
                      //             : "Add new category",
                      //         style: TextStyle(
                      //             fontSize: 12,
                      //             color: Theme.of(context).colorScheme.primary),
                      //       ),
                      //     ))
                    ],
                  );
                }),
                const SizedBox(height: 7.5),
                const Text(
                  "Post Description",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                textFieldWidget(
                    hintText: "Write anything",
                    maxLines: 6,
                    textEditingController: context.read<PostProvider>().postDescriptionController,
                    validator: (value) => validateEmptyFieldWithResponse(value!, "Post descripton cannot be empty"),
                    context: context),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButtonWidget(
                    width: widget.post != null ? 75 : 75,
                    height: 40,
                    radius: 5,
                    onPressed: () {
                      if (context.read<PostProvider>().postFormKey.currentState!.validate()) {
                        context.read<PostProvider>().addPost(
                              context,
                              PostModel(
                                  id: '',
                                  category: context.read<PostProvider>().selectedCategory!,
                                  description: context.read<PostProvider>().postDescriptionController.text,
                                  comments: [],
                                  createdByRef: FirebaseFirestore.instance.doc('users/${context.read<UserProvider>().currentUser!.userId}'),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now()),
                            );
                      }

                      // widget.post != null
                      //     ? context.read<CategoryProvider>().updateCategory(
                      //           context,
                      //           widget.post!,
                      //         )
                      //     : context.read<CategoryProvider>().addCategory(
                      //           context,
                      //           CategoryModel(
                      //               id: "",
                      //               label: context
                      //                   .read<CategoryProvider>()
                      //                   .labelController
                      //                   .text,
                      //               createdAt: DateTime.now(),
                      //               updatedAt: DateTime.now()),
                      //         );
                    },
                    text: widget.post != null ? 'Update' : 'Create',
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  textFieldWidget(
      {required TextEditingController textEditingController,
      required String hintText,
      required String? Function(String?)? validator,
      required BuildContext context,
      Widget? suffixIcon,
      bool? obscureText,
      int? maxLines,
      bool readOnly = false}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 300),
      child: TextFormField(
          controller: textEditingController,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            fillColor: Theme.of(context).cardTheme.color,
            // isCollapsed: true,
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(5.0)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(5.0)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
            hintText: hintText,

            errorStyle: const TextStyle(
              height: 1,
              fontSize: 12.0,
            ),

            hintStyle: const TextStyle(
              height: 1,
              fontSize: 12.0,
            ),

            isDense: true,
            suffixIcon: suffixIcon,
          ),
          maxLines: maxLines,
          readOnly: readOnly,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 12.0, height: 1),
          validator: (value) => validator!(value)),
    );
  }

  Widget iconButton(BuildContext context, IconData iconData, Function() onTap, bool removeIcon) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(
            50,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
              child: Icon(
            color: Theme.of(context).colorScheme.primary,
            iconData,
            size: 12.5,
          )),
        ),
      ),
    );
  }
}
