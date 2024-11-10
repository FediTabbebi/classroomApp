import 'dart:async';

import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClassroomService {
  final CollectionReference _classroomCollection = FirebaseFirestore.instance.collection('classrooms');

  Future<void> addClassroom(ClassroomModel classroom) async {
    try {
      // Assign the document ID to the label field
      classroom.id = _classroomCollection.doc().id;

      // Add the classroom to Firestore
      await _classroomCollection.doc(classroom.id).set(classroom.toJson());
    } catch (e) {
      debugPrint("Error adding classroom: $e");
      rethrow;
    }
  }

  // Stream<List<ClassroomModel>> getMyClassroomAsStream(String userID, BuildContext context) {
  //   StreamController<List<ClassroomModel>> controller = StreamController<List<ClassroomModel>>();

  //   FirebaseFirestore.instance.collection('classrooms').snapshots().listen(
  //     (querySnapshot) async {
  //       List<ClassroomModel> classroomList = [];
  //       for (var doc in querySnapshot.docs) {
  //         Map<String, dynamic> data = doc.data();
  //         DocumentReference createdByRef = data['createdByRef'];
  //         if (createdByRef.id == userID) {
  //           classroomList.add(ClassroomModel.fromMap(data));
  //         }
  //       }
  //       await getAllClassroomsCreatorsAndCommentors(classroomList, context);
  //       controller.add(classroomList);
  //     },
  //     onError: (error) {
  //       if (kDebugMode) {
  //         print('Error getting classrooms: $error');
  //       }
  //     },
  //   );

  //   return controller.stream;
  // }

  Stream<List<ClassroomModel>> getAllClassroomAsStream(String role, String userId, BuildContext context) {
    StreamController<List<ClassroomModel>> controller = StreamController<List<ClassroomModel>>();

    FirebaseFirestore.instance.collection('classrooms').snapshots().listen(
      (querySnapshot) async {
        List<ClassroomModel> classroomList = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();

          // Parse ClassroomModel from the document data
          ClassroomModel classroom = ClassroomModel.fromMap(data);

          // Filter based on the role
          if (role == 'Admin') {
            // Admin: Get all classrooms
            classroomList.add(classroom);
          } else if (role == 'Instructor' && classroom.createdByRef.id == userId) {
            // Instructor: Get classrooms where createdByRef matches userId
            classroomList.add(classroom);
          } else if (role == 'User' && classroom.invitedUsersRef?.any((ref) => ref.id == userId) == true) {
            // User: Get classrooms where invitedUsersRef contains userId
            classroomList.add(classroom);
          }
        }

        // Optional: Populate additional fields if needed
        await getAllClassroomsCreatorsAndCommentors(classroomList, context);

        // Add the list to the stream
        controller.add(classroomList);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error getting classrooms: $error');
        }
        controller.addError(error);
      },
    );

    return controller.stream;
  }

  // Update a classroom
  Future<void> updateClassroom(ClassroomModel classroom) async {
    await _classroomCollection.doc(classroom.id).update(classroom.toJson());
  }

// Delete a classroom
  Future<void> deleteclassroom(String classroomId) async {
    try {
      await _classroomCollection.doc(classroomId).delete();
    } catch (e) {
      debugPrint("Error deleting classroom: $e");
      rethrow;
    }
  }

  Future<void> getAllClassroomsCreatorsAndCommentors(List<ClassroomModel> classrooms, BuildContext context) async {
    // Map to cache user data
    Map<String, UserModel> userCache = {};

    // Collect all creators, commenters, and invited users
    for (var classroom in classrooms) {
      // Fetch creator if not already in cache
      if (!userCache.containsKey(classroom.createdByRef.id)) {
        DocumentSnapshot creatorSnapshot = await classroom.createdByRef.get();
        if (creatorSnapshot.exists) {
          UserModel creator = UserModel.fromMap(creatorSnapshot.data() as Map<String, dynamic>);
          userCache[classroom.createdByRef.id] = creator;
        }
      }
      // Assign creator from cache
      classroom.createdBy = userCache[classroom.createdByRef.id];

      // Fetch commenters if not already in cache
      for (var comment in classroom.comments!) {
        if (!userCache.containsKey(comment.commentedByRef.id)) {
          DocumentSnapshot commentorSnapshot = await comment.commentedByRef.get();
          if (commentorSnapshot.exists) {
            UserModel commentor = UserModel.fromMap(commentorSnapshot.data() as Map<String, dynamic>);
            userCache[comment.commentedByRef.id] = commentor;
          }
        }
        // Assign commenter from cache
        comment.commentedBy = userCache[comment.commentedByRef.id];
      }

      // Fetch invited users if not already in cache
      if (classroom.invitedUsersRef != null) {
        List<UserModel> invitedUsers = [];
        for (var userRef in classroom.invitedUsersRef!) {
          if (!userCache.containsKey(userRef.id)) {
            DocumentSnapshot userSnapshot = await userRef.get();
            if (userSnapshot.exists) {
              UserModel user = UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
              userCache[userRef.id] = user;
              invitedUsers.add(user);
            }
          } else {
            invitedUsers.add(userCache[userRef.id]!); // Add from cache
          }
        }
        // Assign the invited users to the classroom model
        classroom.invitedUsers = invitedUsers;
      }
    }
  }
}
