import 'dart:async';

import 'package:classroom_app/model/remotes/role_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminUserManagementService {
  Stream<List<UserModel>> getUsersStream(String filter) {
    StreamController<List<UserModel>> controller = StreamController<List<UserModel>>();

    FirebaseFirestore.instance.collection('users').snapshots().listen((querySnapshot) {
      List<UserModel> usersList = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        UserModel user = UserModel.fromMap(data);
        // Filter users based on the provided filter argument
        if (filter.isEmpty || user.firstName.toLowerCase().contains(filter.toLowerCase())) {
          usersList.add(user);
        }
      }
      controller.add(usersList);
    }, onError: (error) {
      if (kDebugMode) {
        print('Error getting users: $error');
      }
    });

    return controller.stream;
  }

  Future<List<UserModel>> getUsers() async {
    List<UserModel> usersList = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Create the UserModel from the fetched data
        UserModel user = UserModel.fromMap(data);

        // Fetch the role reference (roleRef) from the user data
        DocumentReference roleRef = user.roleRef;

        // Fetch the role document from the 'roles' collection
        DocumentSnapshot roleDocument = await roleRef.get();

        if (roleDocument.exists) {
          // Safely cast the role data to Map<String, dynamic>
          Map<String, dynamic> roleData = roleDocument.data() as Map<String, dynamic>;

          // Parse the role data into a RoleModel object
          RoleModel role = RoleModel.fromMap(roleData);

          // Set the role in the UserModel
          user.role = role;
        } else {
          print("Role document does not exist for user: ${user.userId}");
        }

        // Add the user with the fetched role to the list
        usersList.add(user);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting users: $e');
      }
    }
    return usersList;
  }

  Future<List<RoleModel>> getAllRoles() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('roles').get();

      // Mapping documents to RoleModel objects
      List<RoleModel> roles = snapshot.docs.map((doc) {
        return RoleModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return roles;
    } catch (e) {
      print("Error fetching roles: $e");
      return []; // Return an empty list in case of error
    }
  }
}
