// import 'package:classroom_app/locator.dart';
// import 'package:classroom_app/model/category_model.dart';
// import 'package:classroom_app/provider/category_provider.dart';
// import 'package:classroom_app/service/categories_service.dart';
// import 'package:classroom_app/src/widget/elevated_button_widget.dart';
// import 'package:classroom_app/src/widget/outlined_button_widget.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:provider/provider.dart';

// class FilterCategoryWidget extends StatefulWidget {
//   final bool isAdmin;
//   const FilterCategoryWidget({required this.isAdmin, super.key});

//   @override
//   State<FilterCategoryWidget> createState() => _FilterCategoryWidgetState();
// }

// class _FilterCategoryWidgetState extends State<FilterCategoryWidget> {
//   final CategoriesService gategoryService = locator<CategoriesService>();

//   final multiKey = GlobalKey<DropdownSearchState<CategoryModel>>();

//   final priorityMultiKey = GlobalKey<DropdownSearchState<String>>();

//   final GlobalKey<DropdownSearchState<String>> popupBuilderKey = GlobalKey<DropdownSearchState<String>>();

//   bool? popupBuilderSelection = false;

//   void handleCheckBoxState({bool updateState = true}) {
//     var selectedItem = popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
//     var isAllSelected = popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
//     popupBuilderSelection = selectedItem.isEmpty ? false : (isAllSelected ? true : null);

//     if (updateState) setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch<CategoryModel>.multiSelection(
//       dropdownButtonProps: DropdownButtonProps(
//         icon: Icon(
//           Ionicons.filter,
//           size: 20,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//       ),
//       // dropdownBuilder: (context, selectedItem) {
//       //   return IconButton(
//       //       onPressed: () {},
//       //       icon: Tooltip(
//       //         message: 'filter posts',
//       //         child: Icon(
//       //           Ionicons.filter,
//       //           color: Theme.of(context).colorScheme.primary,
//       //         ),
//       //       ));
//       // },
//       dropdownBuilder: (context, selectedItems) {
//         return const SizedBox();
//       },
//       dropdownDecoratorProps: const DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//         // focusColor: Colors.transparent,
//         // hoverColor: Colors.transparent,
//         // fillColor: Colors.transparent,

//         errorBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         focusedErrorBorder: InputBorder.none,
//         disabledBorder: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         border: InputBorder.none,
//         filled: false,
//       )),
//       key: multiKey,
//       asyncItems: (String? filter) => gategoryService.getCategories(),
//       itemAsString: (item) {
//         return item.label;
//       },
//       onChanged: (category) {
//         widget.isAdmin ? context.read<CategoryProvider>().notifyAdminSelectedCategory(category) : context.read<CategoryProvider>().notifyAdminSelectedCategory(category);
//       },
//       selectedItems: widget.isAdmin ? context.read<CategoryProvider>().adminSelectedCategories : context.read<CategoryProvider>().userSelectedCategory,
//       compareFn: (item1, item2) {
//         return item1.id == item2.id;
//       },
//       popupProps: PopupPropsMultiSelection.dialog(
//         searchDelay: Duration.zero,
//         dialogProps: DialogProps(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
//         errorBuilder: (context, searchEntry, exception) {
//           return const Center(
//               child: Text(
//             "An error has occured while fetching categories",
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ));
//         },
//         emptyBuilder: (context, searchEntry) {
//           return const Center(
//               child: Text(
//             "It seems like there is no category",
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ));
//         },
//         loadingBuilder: (context, searchEntry) {
//           return const Center(
//               child: Text(
//             "Fetching categories ...",
//             style: TextStyle(fontSize: 16),
//           ));
//         },
//         showSearchBox: true,
//         searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//           isDense: true,
//           hintText: "Search for categories",
//           filled: true,
//           fillColor: Theme.of(context).dialogBackgroundColor,
//         )),
//         containerBuilder: (context, popupWidget) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: SizedBox(
//                       width: 80,
//                       child: OutlinedButtonWidget(
//                         onPressed: () {
//                           multiKey.currentState?.popupDeselectAllItems();
//                           // context
//                           //     .read<
//                           //         ProjectProvider>()
//                           //     .multiKey
//                           //     .currentState
//                           //     ?.popupDeselectAllItems();
//                         },
//                         text: 'None',
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: SizedBox(
//                       width: 80,
//                       child: OutlinedButtonWidget(
//                         onPressed: () {
//                           multiKey.currentState?.popupSelectAllItems();
//                           // context
//                           //     .read<
//                           //         ProjectProvider>()
//                           //     .multiKey
//                           //     .currentState
//                           //     ?.popupSelectAllItems();
//                         },
//                         text: "All",
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Expanded(child: popupWidget),
//             ],
//           );
//         },
//         validationWidgetBuilder: (context, item) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButtonWidget(
//                   radius: 6,
//                   height: 40,
//                   width: 100,
//                   onPressed: () {
//                     multiKey.currentState!.changeSelectedItems(item);
//                     multiKey.currentState!.closeDropDownSearch();
//                     // context
//                     //     .read<ProjectProvider>()
//                     //     .multiKey
//                     //     .currentState!
//                     //     .changeSelectedItems(
//                     //         item);
//                     // context
//                     //     .read<ProjectProvider>()
//                     //     .multiKey
//                     //     .currentState!
//                     //     .closeDropDownSearch();
//                   },
//                   text: 'filter',
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
