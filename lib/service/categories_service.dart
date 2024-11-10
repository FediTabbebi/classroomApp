// import 'package:classroom_app/model/category_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// class CategoriesService {
//   final CollectionReference _categoriesCollection = FirebaseFirestore.instance.collection('categories');

//   Future<void> addCategory(CategoryModel category) async {
//     try {
//       // Assign the document ID to the label field
//       category.id = _categoriesCollection.doc().id;

//       // Add the category to Firestore
//       await _categoriesCollection.doc(category.id).set(category.toJson());
//     } catch (e) {
//       debugPrint("Error adding category: $e");
//       rethrow;
//     }
//   }

//   Future<List<CategoryModel>> getCategories() async {
//     List<CategoryModel> categoriesList = [];
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
//       for (var doc in querySnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         categoriesList.add(CategoryModel.fromMap(data));
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error getting users: $e');
//       }
//     }
//     return categoriesList;
//   }

//   // Update a category
//   Future<void> updateCategory(CategoryModel category) async {
//     try {
//       await _categoriesCollection.doc(category.id).update(category.toJson());
//     } catch (e) {
//       debugPrint("Error updating category: $e");
//       rethrow;
//     }
//   }

// // Delete a category
//   Future<void> deleteCategory(String categoryId) async {
//     try {
//       await _categoriesCollection.doc(categoryId).delete();
//     } catch (e) {
//       debugPrint("Error deleting category: $e");
//       rethrow;
//     }
//   }
// }
