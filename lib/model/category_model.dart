// import 'package:cloud_firestore/cloud_firestore.dart';

// class RoleModel {
//   String id;
//   String label;

//   DateTime createdAt;
//   DateTime updatedAt;

//   RoleModel({
//     required this.id,
//     required this.label,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory RoleModel.fromMap(Map<String, dynamic> map) {
//     return RoleModel(
//       id: map['id'] ?? '',
//       label: map['label'] ?? '',
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       updatedAt: (map['updatedAt'] as Timestamp).toDate(),
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'label': label,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     };
//   }
// }
