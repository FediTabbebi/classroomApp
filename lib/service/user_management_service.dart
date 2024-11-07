import 'dart:async';
import 'package:classroom_app/model/user_model.dart';
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        usersList.add(UserModel.fromMap(data));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting users: $e');
      }
    }
    return usersList;
  }
}
