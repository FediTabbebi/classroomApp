// import 'package:classroom_app/model/category_model.dart';
// import 'package:classroom_app/provider/category_provider.dart';
// import 'package:classroom_app/src/widget/elevated_button_widget.dart';
// import 'package:classroom_app/utils/helper.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';

// class AddOrUpdateCategoryDialog extends StatefulWidget {
//   final CategoryModel? category;
//   const AddOrUpdateCategoryDialog({this.category, super.key});

//   @override
//   State<AddOrUpdateCategoryDialog> createState() => _AddOrUpdateUserDialogState();
// }

// class _AddOrUpdateUserDialogState extends State<AddOrUpdateCategoryDialog> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<CategoryProvider>().clearControllers();
//     if (widget.category != null) {
//       context.read<CategoryProvider>().initControllers(widget.category!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Dialog(
//         backgroundColor: Theme.of(context).cardTheme.color,
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//         child: Form(
//           key: context.read<CategoryProvider>().categoryFormKey,
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Align(
//                     alignment: Alignment.topRight,
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                         context.read<CategoryProvider>().clearControllers();
//                       },
//                       child: Icon(
//                         size: 20,
//                         FontAwesomeIcons.xmark,
//                         color: Theme.of(context).hintColor,
//                       ),
//                     )),
//                 Text(
//                   widget.category != null ? "Update Category" : " Create Category",
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 10.0),
//                 textFieldWidget(
//                     hintText: "Category label",
//                     textEditingController: context.read<CategoryProvider>().labelController,
//                     validator: (value) => validateEmptyField(
//                           value!,
//                         ),
//                     context: context),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: ElevatedButtonWidget(
//                     width: widget.category != null ? 75 : 60,
//                     height: 40,
//                     radius: 5,
//                     onPressed: () {
//                       if (context.read<CategoryProvider>().categoryFormKey.currentState!.validate()) {
//                         widget.category != null
//                             ? context.read<CategoryProvider>().updateCategory(
//                                   context,
//                                   widget.category!,
//                                 )
//                             : context.read<CategoryProvider>().addCategory(
//                                   context,
//                                   CategoryModel(id: "", label: context.read<CategoryProvider>().labelController.text, createdAt: DateTime.now(), updatedAt: DateTime.now()),
//                                 );
//                       }
//                     },
//                     text: widget.category != null ? 'update' : 'Add',
//                     fontSize: 12,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   textFieldWidget(
//       {required TextEditingController textEditingController,
//       required String hintText,
//       required String? Function(String?)? validator,
//       required BuildContext context,
//       Widget? suffixIcon,
//       bool? obscureText,
//       bool readOnly = false}) {
//     return Container(
//       constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
//       child: TextFormField(
//           controller: textEditingController,
//           obscureText: obscureText ?? false,
//           decoration: InputDecoration(
//             alignLabelWithHint: true,
//             fillColor: Theme.of(context).cardTheme.color,
//             // isCollapsed: true,
//             errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(5.0)),
//             enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(5.0)),
//             focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
//             focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
//             hintText: hintText,

//             errorStyle: const TextStyle(
//               height: 1,
//               fontSize: 12.0,
//             ),

//             hintStyle: const TextStyle(
//               height: 1,
//               fontSize: 12.0,
//             ),

//             isDense: true,
//             suffixIcon: suffixIcon,
//           ),
//           readOnly: readOnly,
//           textAlign: TextAlign.start,
//           style: const TextStyle(fontSize: 12.0, height: 1),
//           validator: (value) => validator!(value)),
//     );
//   }

//   Widget iconButton(BuildContext context, IconData iconData, Function() onTap, bool removeIcon) {
//     return Container(
//       height: 20,
//       width: 20,
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.all(
//           Radius.circular(
//             50,
//           ),
//         ),
//       ),
//       child: InkWell(
//         onTap: () {
//           onTap();
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: Center(
//               child: Icon(
//             color: Theme.of(context).colorScheme.primary,
//             iconData,
//             size: 12.5,
//           )),
//         ),
//       ),
//     );
//   }
// }
